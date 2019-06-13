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
void createDouble(string id);
void createShow();
void createRead(string id);
void initValues();
void stopIf();
void startIf();
void changeValue(string id);
string getName();

static int dint = 0;
static int labelNum = 0;

extern int yyerror(char *msg,...);
extern "C" int yylex();
extern "C" int yyerror(const char*msg,...);
vector<string> code;
vector<string> codef;

#define INT1 1
#define DOUBLE2 2
#define STRING3 3

struct zmienna {
string wartosc;
int iwartosc;
double dwartosc;
int typ;

zmienna()
{

}
zmienna(int iwartosc)
{
	this->iwartosc = iwartosc;
	this->typ = INT1;
}
zmienna(double dwartosc)
{
	this->dwartosc = dwartosc;
	this->typ = DOUBLE2;
}
zmienna(string wartosc)
{
	this->wartosc = wartosc;
	this->typ = STRING3;
}
};
string getValue(zmienna id)
{
	if(id.typ == INT1)
		return to_string(id.iwartosc);
	if(id.typ == DOUBLE2)
		return to_string(id.dwartosc);
	if(id.typ == STRING3)
		return id.wartosc;
}

stack<zmienna> stos;
stack<string> logOperator;
stack<string> labels;
map <string,zmienna> symbols;

%}

%union 
{char *text;
int	ival;
double  dval;};
%token <text> ID 
%token <ival> LC
%token <dval> LP
%token START ENDD END
%token LEQ GEQ EQ NEQ
%token INTEGER DOUBLE 
%token IF WHILE 
%token ARRAY DARRAY
%token SHOW NL READ
%%

wlinii
	:wlinii linia		{printf("wl\n");}
	|linia			{printf("l\n");}
	;

linia
	:przyp ';'
	|io ';'
	|if_expr {} 
	;
if_expr
	: if_start '{' wlinii '}' { stopIf(); }
	;
if_start
	: IF '(' wyr operatorLog wyr ')' { startIf(); }
	;
przyp
	:INTEGER ID '=' wyr {createInteger($2);}
	|DOUBLE ID '=' wyr {createDouble($2);}
	|ID '=' wyr		{writeRPN($1); changeValue($1);}
	//|ID '=' wyr		{writeRPN($1); stos.push(zmienna($1)); writeTriple("=");}
	;
io
	:SHOW wNawiasach {createShow();}
	|READ '(' ID ')'{createRead($3);}
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
operatorLog
	: EQ  {logOperator.push("bne");}
	| NEQ {logOperator.push("beq");}
	| GEQ {logOperator.push("blt");}
	| LEQ {logOperator.push("bgt");}
	| '>' {logOperator.push("ble");}
	| '<' {logOperator.push("bge");}
	;
czynnik
	:ID			{writeRPN($1); stos.push(zmienna($1)); } 
	|LC			{char buff[512]; sprintf(buff,"%d",$1); writeRPN(buff);
                                 stos.push(zmienna($1));}
	|LP			{char buff[512]; sprintf(buff,"%f",$1); writeRPN(buff); 
				stos.push(zmienna($1));}
	|wNawiasach		{ ;}
	;
wNawiasach
	:'(' wyr ')'		{}
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
 stringstream stream;
 static int it = 0; 
 stream << "result" << it;
 it++;
 string result = stream.str();

 zmienna arc2 = stos.top();// asdf, dd, 67, 679, 7.9
 stos.pop();
 zmienna arc1 = stos.top();
 stos.pop();

 //string type_of1 = isdigit(arc1[0]) ? "i" : "w";
 //string type_of2 = isdigit(arc2[0]) ? "i" : "w";

 int typ1=0;
 int typ2=0;

 if(arc2.typ == STRING3)
 {
	zmienna value = symbols.at(arc2.wartosc);
	typ2 = value.typ;
 }
 else
 {
	typ2 = arc2.typ;
 } 
 if(arc1.typ == STRING3)
 {
	zmienna value = symbols.at(arc1.wartosc);
	typ1 = value.typ;
 }
 else
 {
	typ1 = arc1.typ;
 }

 if(typ2 == DOUBLE2 && typ1 == INT1)
 { 
	yyerror("ERROR float and int together !\n");
 }

 if(typ1 == DOUBLE2 && typ2 == INT1)
 {
	yyerror("ERROR float and int together !\n");
 }

 string type_of1;
 string type_of2;
 string type1;
 string type2;

 if(arc1.typ == INT1)
 {
 	type_of1 = "i"; //li
 	type1 = "t"; //$t0
 }
 else if(arc1.typ == DOUBLE2)
 {
 	type_of1 = ".s"; //l.s
 	type1 = "f"; //$f0
 }
 else
 {
 	zmienna value = symbols.at(arc1.wartosc);	
 	if(value.typ == INT1)
 		type_of1 = "w";
 	else
 		type_of1 = ".s";
 }
 	

 if(arc2.typ == INT1)
 	{
 		type_of2 = "i"; //li
 		type2 = "t"; //$t0
 	}
 else if(arc2.typ == DOUBLE2)
 	{
 		type_of2 = ".s"; //l.s
 		type2 = "f"; //$f0
 	}
 else
 	{
 	zmienna value = symbols.at(arc2.wartosc);	
 	if(value.typ == INT1)
 		type_of2 = "w";
 	else
 		type_of2 = ".s";
	}

 stringstream stream2;
 static int it2 = 0;
 it2++; 
 stream2 << "result" << it2;
 it2++;
 string name = stream2.str();

 if(arc2.typ == STRING3)
 	symbols[name] = arc2;

 stringstream stream3;
 it2++;
 stream3 << "result" << it2;
 name = stream3.str();

 if(arc1.typ == STRING3)
 	symbols[name] = arc1;


 code.push_back("l" + type_of1 + " $"+type1+"0 , "+ getValue(arc1));
	if(znak == "=")
	{
	cout<<getValue(arc1)<<" "<<getValue(arc2)<<endl;
	stringstream stream4;

	string tmpName;
	for (std::map<string,zmienna>::iterator it=symbols.begin(); it!=symbols.end(); ++it)
	{
		if(it->second.typ == arc2.typ && it->second.wartosc == arc2.wartosc && it->second.iwartosc == arc2.iwartosc && it->second.dwartosc == arc2.dwartosc)
			tmpName = it->first;
	}

	stream4<<"sw $"+type1+"0 , "<<tmpName;
	cout<<"typeof1: "<<type_of1<<endl;
	code.push_back(stream4.str());
	}
	else
	{
	 	code.push_back("l" + type_of2 + " $"+type2+"1 , "+ getValue(arc2));
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
 		symbols[result] = zmienna(0);


	}

 code.push_back(" ");

 // zapis do pliku
 cout << "W: " << result << " = " << getValue(arc1) << " " << znak << " " << getValue(arc2) << endl;

 fstream pFile("triplelog.txt", std::fstream::app);
 pFile<<"W: "<< result << " = " << getValue(arc1) << " " << znak << " " << getValue(arc2)<<endl;
 pFile.close();

 stos.push(zmienna(result));
}

void header()
{
	codef.push_back(".data");
	for (std::map<string,zmienna>::iterator it=symbols.begin(); it!=symbols.end(); ++it)
	{
		stringstream tmp;
		if(it->second.typ == DOUBLE2)
        	tmp << it->first << ":	.float	"<<it->second.dwartosc;
        else
        	tmp << it->first << ":	.word	0";
		codef.push_back(tmp.str());
		//": .float  " << symbol.fVal << endl;
	}	
}

void initValues()
{
	codef.push_back("\n.text");

	for (std::map<string,zmienna>::iterator it=symbols.begin(); it!=symbols.end(); ++it)
	{
		if(it->second.typ == INT1)
		{
			stringstream tmp,tmp2;
			tmp <<"li $t0, "<<it->second.iwartosc;
       		codef.push_back(tmp.str());
       		tmp2 <<"sw $t0, "<<it->first;
       		codef.push_back(tmp2.str());
		}
	}	

	for(auto line: code)
		codef.push_back(line);
}

void createShow()
{
	if(stos.top().typ == INT1)
	{
		code.push_back("li $v0, 1");
		stringstream tmp;
		tmp <<"li $a0, "<<stos.top().iwartosc;
		code.push_back(tmp.str());
	}
	if(stos.top().typ == DOUBLE2)
	{
		string name = getName();
		symbols[name] = zmienna(stos.top().dwartosc);
		code.push_back("li $v0, 2");
		stringstream tmp;
		tmp <<"l.s $f12, " << name;
		code.push_back(tmp.str());
	}
	if(stos.top().typ == STRING3)
	{
		zmienna value = symbols.at(stos.top().wartosc);

		if(value.typ == INT1)
		{
			code.push_back("li $v0, 1");
			stringstream tmp;
			tmp <<"lw $a0, "<< stos.top().wartosc;
			code.push_back(tmp.str());
		}
		if(value.typ == DOUBLE2)
		{
			code.push_back("li $v0, 2");
			stringstream tmp;
			tmp <<"l.s $f12, "<< stos.top().wartosc;
			code.push_back(tmp.str());
		}
	}
 code.push_back("syscall");
}

void createRead(string id)
{
	zmienna value = symbols.at(id);
	if(value.typ == INT1)
	{
		code.push_back("li $v0, 5");
		code.push_back("syscall");
		stringstream tmp;
		tmp<<"sw $v0, "<<id;
		code.push_back(tmp.str());
	}
	if(value.typ == DOUBLE2)
	{
		code.push_back("li $v0, 6");
		code.push_back("syscall");
		stringstream tmp;
		tmp<<"s.s $f0, "<<id;
		code.push_back(tmp.str());		
	}
}

void createInteger(string id)
{
	if(stos.top().typ == DOUBLE2)
		yyerror("error: double -> int type mismatch\n");
	if(stos.top().typ == STRING3)
	{
		zmienna value = symbols.at(stos.top().wartosc);

		if(value.typ == DOUBLE2)
			yyerror("error: double -> int type mismatch\n");	
	}

	symbols[id] = zmienna(stos.top());
	stos.pop();
}

void createDouble(string id)
{
	if(stos.top().typ == INT1)
		yyerror("error: int -> double type mismatch\n");
	else if(stos.top().typ == STRING3)
	{
		zmienna value = symbols.at(stos.top().wartosc);
	
		if(value.typ == INT1)
			yyerror("error: int -> double type mismatch\n");
	}
	symbols[id] = zmienna(stos.top());
	stos.pop();
	//myStack.pop();
}

string getName()
{
	string name;
	stringstream tmp;
	tmp <<"dvar"<< dint;
	name = tmp.str();
	dint ++;
	return name;
}

void startIf()
{
	code.push_back("# startIf");
	if(stos.top().typ == INT1)
	{
		stringstream tmp;
		tmp <<"li $t1, "<< stos.top().iwartosc;
		code.push_back(tmp.str());
	}
	else
	{
		stringstream tmp2;
		tmp2 <<"lw $t1, "<< stos.top().wartosc;
		code.push_back(tmp2.str());  
	}
	stos.pop();
 
	if(stos.top().typ == INT1)
	{
		stringstream tmp3;
		tmp3 <<"li $t0, "<< stos.top().iwartosc;
		code.push_back(tmp3.str());
	}
	else
	{
		stringstream tmp4;
		tmp4 <<"lw $t0, "<< stos.top().wartosc;
		code.push_back(tmp4.str()); 
	}
	stos.pop();
	code.push_back(logOperator.top() + " $t0, $t1, label" + to_string(labelNum));
	logOperator.pop();
	labels.push("label" + to_string(labelNum));
	labelNum++;
}

void stopIf()
{
	code.push_back(labels.top() + ":");
	labels.pop();
}

void changeValue(string id)
{
	zmienna var2 = stos.top();

	zmienna var1 = symbols.at(id);

	int type1, type2;

	if (var2.typ == INT1 && var1.typ == INT1)
	{
		code.push_back("li $t0, " + std::to_string(var2.iwartosc));
		code.push_back("sw $t0, " + id);
	}
	if (var2.typ == STRING3 && var1.typ == INT1)
	{
		zmienna varTmp = symbols.at(var2.wartosc);
		if(varTmp.typ == INT1)
		{
			code.push_back("sw $t0, " + var2.wartosc);
			code.push_back("sw $t0, " + id);
		}
		if(varTmp.typ == DOUBLE2)
		{
			yyerror("blad typow ! double -> int ");
		}	
	}

	if (var2.typ == STRING3 && var1.typ == DOUBLE2)
	{
		zmienna varTmp = symbols.at(var2.wartosc);
		if(varTmp.typ == INT1)
		{
			yyerror("blad typow ! int -> double ");
		}
		if(varTmp.typ == DOUBLE2)
		{
			code.push_back("s.s $f0, " + var2.wartosc);
			code.push_back("s.s $f0, " + id);
		}
	}

	/*  //wziete z SHOW

		string name = getName();
		symbols[name] = zmienna(stos.top().dwartosc);
		code.push_back("li $v0, 2");
		stringstream tmp;
		tmp <<"l.s $f12, " << name;
		code.push_back(tmp.str());
	*/
}


int main(int argc, char *argv[])
{		

	//fstream pFile("triplelog.txt", std::fstream::out);
	//pFile.close();
	fstream pFile("code.asm", std::fstream::out);
	pFile.close();
	yyparse();
	header();
	initValues();	
	fstream codeFile("code.asm", std::fstream::out);
	
	for(auto line: codef)
		codeFile<<line<<endl;

	codeFile.close();
	return 0;
}


