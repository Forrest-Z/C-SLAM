%{
	#include <sstream>
	#include <stdexcept>
	#include <string>
	#include "TreeClassifierScanner.h"
	
	#define YY_USER_ACTION this->count(yyleng);
	
	#define UNKNOWN -1
	
	typedef tc::TreeClassifierParser::token token;
	
	using namespace std;
%}


%option yylineno
%option debug 
%option nodefault 
%option yyclass="TreeClassifierScanner" 
%option noyywrap 
%option c++

%x COMMENT

DIGIT [0-9]
CAPITAL [A-Z]
LETTER [a-z]|{CAPITAL}
BLANK [ \t]
NEWLINE \n\r|\n
SIGN [-+]

%%

 /* C++ stle nested comment eater */
"/*" { saveLastState(YY_START); BEGIN(COMMENT); }
<COMMENT>
{
	[^/*]*
	"/"+[^*/]*
	"/*" { saveLastState(YY_START); BEGIN(COMMENT); }
	"*"+[^*/]*
	"*"+"/" { BEGIN(getLastState()); }
}
 /* blank and new line */
{BLANK} { }
{NEWLINE} { this->newLine(); }

 /* keywords and symbols */
"class"|"CLASS" { return token::CLASS; }
"end_class"|"END_CLASS" { return token::END_CLASS; }
"is"|"IS" { return token::IS; }
"match"|"MATCH" { return token::MATCH; }
"between"|"BETWEEN" { return token::BETWEEN; }
"variables"|"VARIABLES"  { return token::VARIABLES; }
"end_variables"|"END_VARIABLES"  { return token::END_VARIABLES; }
"constants"|"CONSTANTS"  { return token::CONSTANTS; }
"end_constants"|"END_CONSTANTS"  { return token::END_CONSTANTS; }
"important"|"IMPORTANT" { return token::IMPORTANT; }
"extends"|"EXTENDS" { return token::EXTENDS; }
"=" { return token::EQUAL; }
"," { return token::COMMA; }
"." { return token::PERIOD; }
";" { return token::SEMICOLON; }
"(" { return token::LPAR; }
")" { return token::RPAR; }

 
 /* identificators */
{CAPITAL}({LETTER}|{DIGIT})* { yylval->str = new std::string(yytext); return token::ID; }
{SIGN}?{DIGIT}+ { yylval->integer = atoi(yytext); return token::NUMBER; }

 /* unknown tokens */
. { std::stringstream ss; ss << "Error: Unknown char " << *yytext << " at line " << this->getLine() << ", column " << this->getColumn() << endl; throw std::runtime_error(ss.str()); }