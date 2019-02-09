%{
#include<stdlib.h>
#include<stdio.h>
#define YYDEBUG 1
//#include"syntabs.h" // pour syntaxe abstraite
//extern n_prog *n;   // pour syntaxe abstraite
extern FILE *yyin;    // declare dans compilo
extern int yylineno;  // declare dans analyseur lexical
int yylex();          // declare dans analyseur lexical
int yyerror(char *s); // declare ci-dessous
%}

%token OU 
%token ET  
%token NON  
%token EGAL  
%token INFERIEUR
%token SUPERIEUR  
%token PLUS  
%token MOINS  
%token FOIS 
%token DIVISE 
%token PARENTHESE_OUVRANTE 
%token PARENTHESE_FERMANTE 
%token IDENTIF
%token NOMBRE
%token POINT_VIRGULE
%token CROCHET_OUVRANT
%token CROCHET_FERMANT
%token ACCOLADE_OUVRANTE
%token ACCOLADE_FERMANTE
%token SI
%token ALORS
%token SINON
%token TANTQUE
%token FAIRE
%token ENTIER
%token RETOUR
%token LIRE
%token ECRIRE
%token VIRGULE


%start programme
%%

// Axiome de la grammaire
programme : ensembleDecDef
	|
	;
ensembleDecDef : decDef ensembleDecDef
	|	decDef
	;
decDef : ligneDeclarationsVars
	| definitionFct
	;
	

// grammaire des expressions arithmetiques 

expressionArithmetique : expressionArithmetique OU conjonction
		|	conjonction
		;
conjonction : conjonction ET comparaison
		|	comparaison
		;
comparaison	: comparaison EGAL somme
		|	comparaison INFERIEUR somme
		|	comparaison SUPERIEUR somme
		| somme
		;
somme : somme PLUS produit
	|	somme MOINS produit
	|	produit
	;
produit : produit FOIS negation
	|	produit DIVISE negation
	|	negation
	;
negation : NON expressionPrioritaire
	| expressionPrioritaire
	;
expressionPrioritaire : PARENTHESE_OUVRANTE expressionArithmetique PARENTHESE_FERMANTE
		|	var
		|	NOMBRE
		| 	fonction
		;
var : IDENTIF
	| 	IDENTIF CROCHET_OUVRANT expressionArithmetique CROCHET_FERMANT
	;
fonction : LIRE PARENTHESE_OUVANTE PARENTHESE_FERMANTE
	|	ECRIRE PARENTHESE_OUVRANTE expressionArithmetique PARENTHESE_FERMANTE
	| 	IDENTIF PARENTHESE_OUVRANTE argument PARENTHESE_FERMANTE
	;
argument : listArg
		|
		;

listArg : expressionArithmetique
	|	expressionArithmetique VIRGULE listArg
	;
	

// Grammaire des instructions

instruction : affectation
	|	condition
	|	boucle
	|	retour
//	|	appelFonction
	|	blocInstructions
	|	instructionVide
	|	instructionArithmetique
	;
affectation : var EGAL expressionArithmetique POINT_VIRGULE ;
condition : SI expressionArithmetique ALORS blocInstructions
	|	SI expressionArithmetique ALORS blocInstructions SINON blocInstructions
	;
boucle : TANTQUE expressionArithmetique FAIRE blocInstructions ;
retour : RETOUR expressionArithmetique POINT_VIRGULE ;
//appelFonction : fonction POINT_VIRGULE ;											// Pris en compte dans instructionArithmetique
blocInstructions : ACCOLADE_OUVRANTE listInstructions ACCOLADE_FERMANTE ;
listInstructions : instructions
	|
	;
instructions : instruction instructions ;
instructionvide : POINT_VIRGULE ;

//// instructionArithmetique
instructionArithmetique : instDisj POINT_VIRGULE ;
instDisj : instDisj OU instConj
	| 	instConj
	;
instConj : instConj ET instComp
	|	instComp
	;
instComp : instComp INFERIEUR somme
	|	instComp SUPERIEUR somme
	|	somme
	;


// Grammaire des declarations de variables

blocDeclarationsVarsLocales : ensembleDeclarationsVarLocales 
	|	
	;
ensembleDeclarationsVarLocales : ensembleDeclarationsVarLocales ligneDeclarationsVars 			// Util?
	|	ligneDeclarationsVars
	;
	
declarationsArgs : declarationsVars
	|	
	;
	
ligneDeclarationsVars : declarationsVars POINT_VIRGULE ;
declarationsVars : declarationVar VIRGULE declarationsVars
	|	declarationVar
	;
declarationVar : ENTIER IDENTIF 
	|	ENTIER IDENTIF CROCHET_OUVRANT expressionArithmetique CROCHET_FERMANT 
	;
	

// Grammaire des definitions de fonctions

definitionFct : IDENTIF PARENTHESE_OUVRANTE declarationsArgs PARENTHESE_FERMANTE blocDeclarationsVarsLocales blocInstructions ;






%%

int yyerror(char *s) {
  fprintf(stderr, "erreur de syntaxe ligne %d\n", yylineno);
  fprintf(stderr, "%s\n", s);
  fclose(yyin);
  exit(1);
}
