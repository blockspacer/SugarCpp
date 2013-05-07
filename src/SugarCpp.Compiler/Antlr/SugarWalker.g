tree grammar SugarWalker ;

options
{
    tokenVocab=SugarCpp;   
    ASTLabelType=CommonTree;  
    language=CSharp3;
}

@header
{
	using System;
	using System.Collections;
	using System.Linq;
}

@members
{
}

@namespace { SugarCpp.Compiler }

public root returns [Root value]
	: ^(Root a=global_block)
	{
		$value = new Root(a);
	}
	;

global_block returns [GlobalBlock value]
@init
{
	$value = new GlobalBlock();
}
	: ^(Global_Block (a=node { $value.List.Add(a); })*)
	;

node returns [AttrAstNode value]
	: a = func_def { $value = a; }
	| b = import_def { $value = b; }
	| c = enum_def { $value = c; }
	| d = class_def { $value = d; }
	| e = global_alloc { $value = e; }
	| f = global_using { $value = f; }
	| g = global_typedef { $value = g; }
	| h = namespace_def { $value = h; }
	;

global_using returns[GlobalUsing value]
	: a=stmt_using
	{
		$value = new GlobalUsing(a.List);
	}
	;

global_alloc returns [GlobalAlloc value]
	: ^(Expr_Alloc_Equal (attr=attribute)? a=type_name b=ident_list (c=expr_list)?)
	{
		$value = new GlobalAlloc(a, b, c, attr, true);
	}
	| ^(Expr_Alloc_Bracket (attr=attribute)? a=type_name b=ident_list (c=expr_list)?)
	{
		$value = new GlobalAlloc(a, b, c, attr, false);
	}
	| ^(':=' (attr=attribute)? a=ident c=expr_list)
	{
		$value = new GlobalAlloc("auto", new List<string> { a }, c, attr, true);
	}
	;

global_typedef returns [GlobalTypeDef value]
	: a=stmt_typedef
	{
		$value = new GlobalTypeDef(a.Type, a.Name);
	}
	;

attribute_args returns [string value]
	: a=(NUMBER)
	{
		$value = a.Text;
	}
	| a=STRING
	{
		$value = a.Text.Substring(1, a.Text.Length - 2);
	}
	| b=ident
	{
		$value = b;
	}
	;

attribute_item returns [Attr value]
@init
{
	$value = new Attr();
}
	: ^(Attribute (a=ident { $value.Name = a; } | c='const' { $value.Name = "const"; }) (b=attribute_args { $value.Args.Add(b) ; })*)
	;

attribute returns [List<Attr> value]
@init
{
	$value = new List<Attr>();
}
	: (a=attribute_item { $value.Add(a); } )+
	;

namespace_def returns [Namespace value]
	: ^(Namespace a=ident b=global_block)
	{
		$value = new Namespace(a, b);
	}
	;

import_def returns [Import value]
@init
{
	$value = new Import();
}
	: ^(Import (a=STRING { $value.NameList.Add(a.Text); })*)
	;

enum_def returns [Enum value]
	: ^(Enum (attr=attribute)? a=ident b=ident_list)
	{
		$value = new Enum(a, b, attr);
	}
	;

class_def returns [Class value]
	: ^(Class (attr=attribute)? a=ident (b=generic_parameter)? (c=func_args)? (d=ident_list)? (e=global_block)?)
	{
		$value = new Class(a, b, c, d, e, attr);
	}
	;

type_name returns [string value]
@init
{
	$value = "";
}
	: ^( Type_IDENT
	     ('const' { $value += "const "; })?
		 ('unsigned' { $value += "unsigned "; })?
	     a=ident { $value+=a; }
	   ( '<' { $value+="<"; bool isFirst = true; }
	    (b=type_name
		{
			if (!isFirst) $value+=", ";
			isFirst = false;
			$value+=b;
		})*
		'>' { $value+=">"; })?
	  ( '*' { $value+="*"; }
	  | '[' ']' { $value+="[]"; }
	  | '&' { $value+="&"; }
	  )*)
	;

func_args returns [List<ExprAlloc> value]
@init
{
	$value = new List<ExprAlloc>();
}
	: ^(Func_Args (a=stmt_alloc
	{
		var b = (ExprAlloc)a;
		if (b.Type == "auto")
		{
			b.Type = "decltype";
		}
		$value.Add(b);
	})*)
	;

generic_parameter returns [List<string> value]
@init
{
	$value = new List<string>();
}
	: ^(Generic_Patameters (a=ident { $value.Add(a); })*)
	;

func_def returns [FuncDef value]
@init
{
	$value = new FuncDef();
}
	: ^(Func_Def (attr=attribute)? (a=type_name)? (deconstructor='~')? b=ident (x=generic_parameter )? (args=func_args { $value.Args = args; })?
	( e=stmt_block
	{
		if (attr != null) $value.Attribute = attr;
		$value.Type = a;
		$value.Name = b;
		if (deconstructor != null) 
		{
			$value.Name = "~" + $value.Name;
		}
		if (x != null)
		{
			$value.GenericParameter = x;
		}
		$value.Body = e;
	}
	| f=expr
	{
		if (attr != null) $value.Attribute = attr;
		$value.Type = a;
		$value.Name = b;
		if (deconstructor != null) 
		{
			$value.Name = "~" + $value.Name;
		}
		StmtBlock block = new StmtBlock();
		if (a == "void" || a == null)
		{
			block.StmtList.Add(new StmtExpr(f));
		}
		else
		{
			block.StmtList.Add(new StmtReturn(f));
		}
		if (x != null)
		{
			$value.GenericParameter = x;
		}
		$value.Body = block;
	}
	))
	;

stmt_block returns [StmtBlock value]
@init
{
	$value = new StmtBlock();
}
	: ^(Stmt_Block (a=stmt { $value.StmtList.Add(a); })*)
    ; 

stmt returns [Stmt value]
	: a=stmt_expr { $value = new StmtExpr(a); }
	| a=stmt_return { $value = a; }
	| a=stmt_if { $value = a; }
	| a=stmt_while { $value = a; }
	| a=stmt_for { $value = a; }
	| a=stmt_try { $value = a; }
	| a=stmt_linq { $value = a; }
	| a=stmt_defer { $value = a; }
	;

stmt_defer returns [Stmt value]
	: ^(Stmt_Defer a=stmt)
	{
		$value = new StmtDefer(a);
	}
	;

stmt_expr returns [Stmt value]
	: a=stmt_using { $value = a; }
	| b=expr { $value = b; }
	| c=stmt_typedef { $value = c; }
	;

stmt_using returns [StmtUsing value]
@init
{
	$value = new StmtUsing();
}
	: ^(Stmt_Using ( a=ident { $value.List.Add(a); }
				   | b='namespace' { $value.List.Add("namespace"); })*)
	;

stmt_typedef returns [StmtTypeDef value]
	: ^(Stmt_Typedef a=type_name b=ident)
	{
		$value = new StmtTypeDef(a, b);
	}
	;

stmt_alloc returns [Stmt value]
	: a=expr { $value = a; }
	;

stmt_if returns [Stmt value]
	: ^(Stmt_If a=expr b=stmt_block (c=stmt_block)?)
	{
		$value = new StmtIf(a, b, c);
	}
	;

stmt_while returns [Stmt value]
	: ^(Stmt_While a=expr b=stmt_block)
	{
		$value = new StmtWhile(a, b);
	}
	| ^(Stmt_Loop b=stmt_block)
	{
		$value = new StmtWhile(new ExprConst("true", ConstType.Ident), b);
	}
	;

stmt_for returns [Stmt value]
	: ^(Stmt_For a=expr b=expr c=expr d=stmt_block)
	{
		
		$value = new StmtFor(a, b, c, d);
	}
	| ^(Stmt_ForEach a=expr b=expr d=stmt_block)
	{
		$value = new StmtForEach(a, b, d);
	}
	;

stmt_try returns [Stmt value]
	: ^(Stmt_Try a=stmt_block b=expr c=stmt_block)
	{
		$value = new StmtTry(a, b, c);
	}
	;

stmt_return returns [Stmt value]
	: ^(Stmt_Return (a=expr)?)
	{
		$value = new StmtReturn(a);
	}
	;

linq_item returns [LinqItem value]
	: ^(Linq_From x=expr b=expr)
	{
		$value = new LinqFrom(x, b);
	}
	| ^(Linq_Let a=ident b=expr)
	{
		$value = new LinqLet(a, b);
	}
	| ^(Linq_Where b=expr)
	{
		$value = new LinqWhere(b);
	}
	;

linq_prefix returns [List<LinqItem> value]
@init
{
	$value = new List<LinqItem>();
}
	: ^(Linq_Prefix (a=linq_item { $value.Add(a); })+)
	;

stmt_linq returns [Stmt value]
	: ^(Stmt_Linq a=linq_prefix b=stmt_block)
	{
		$value = new StmtLinq(a, b);
	}
	;

ident returns [string value]
@init
{
	$value = "";
}
	: a=IDENT { $value = a.Text; } ('::' a=IDENT { $value += "::" + a.Text; })*
	;

ident_list returns [List<string> value]
@init
{
	$value = new List<string>();
}
	: ^(Ident_List (a=ident { $value.Add(a); })*)
	;
	
alloc_expr returns [ExprAlloc value]
	: ^(Expr_Alloc_Equal a=type_name b=ident_list (c=expr_list)?)
	{
		$value = new ExprAlloc(a, b, c, true);
	}
	| ^(Expr_Alloc_Bracket a=type_name b=ident_list (c=expr_list)?)
	{
		$value = new ExprAlloc(a, b, c, false);
	}
	;

expr_tuple returns [ExprTuple value]
@init
{
	$value = new ExprTuple();
}
	: ^(Expr_Tuple (a=expr { $value.ExprList.Add(a); })+ )
	;

match_tuple returns [MatchTuple value]
@init
{
	$value = new MatchTuple();
}
	: ^(Match_Tuple (a=expr { $value.ExprList.Add(a); })*)
	;

expr_list returns [List<Expr> value]
@init
{
	$value = new List<Expr>();
}
	: (a=expr { $value.Add(a); })+
	;

call_expr returns [ExprCall value]
	: ^(Expr_Call a=expr (b=generic_parameter)? (c=expr_list)?)
	{
		$value = new ExprCall(a, b, c);
	}
	;

dict_expr returns [Expr value]
	: ^(Expr_Dict a=expr (b=expr_list)?)
	{
		$value = new ExprDict(a, b);
	}
	;

lambda_expr returns [ExprLambda value]
	: ^(Expr_Lambda (b=func_args)? a=expr)
	{
		$value = new ExprLambda(a, b);
	}
	;

new_expr returns [Expr value]
	: ^(Expr_New_Type a=type_name b=expr_list?)
	{
		$value = new ExprNewType(a, b);
	}
	| ^(Expr_New_Array a=type_name b=expr_list)
	{
		$value = new ExprNewArray(a, b);
	}
	;

call_with_expr returns [ExprCall value]
	: ^(Expr_Call_With a=expr b=ident c=expr_list?)
	{
		List<Expr> Args = new List<Expr>();
		Args.Add(a);
		if (c != null)
		{
			foreach (var item in c)
			{
				Args.Add(item);
			}
		}
		$value = new ExprCall(new ExprConst(b, ConstType.Ident), null, Args);
	}
	;

expr returns [Expr value]
    : tuple=expr_tuple
	{
		$value = tuple;
	}
	| alloc=alloc_expr
	{
		$value = alloc;
	}
	| match=match_tuple
	{
		$value = match;
	}
	| call=call_expr
	{
		$value = call;
	}
	| call_with=call_with_expr
	{
		$value = call_with;
	}
	| dict=dict_expr
	{
		$value = dict;
	}
	| lambda=lambda_expr
	{
		$value = lambda;
	}
	| expr_new=new_expr
	{
		$value = expr_new;
	}
	| ^(Expr_Infix ident_text=ident a=expr b=expr)
	{
		$value = new ExprInfix(ident_text, a, b);
	}
	| ^(Expr_Cond a=expr b=expr c=expr)
	{
		$value = new ExprCond(a, b, c);
	}
	| ^(Expr_Access op=('.' | '::' | '->' | '->*' | '.*') a=expr ident_text=ident)
	{
		$value = new ExprAccess(a, op.Text, ident_text);
	}
	| ^(Expr_Bin op=( '+' | '-' | '*' | '/' | '%'
					| '<' | '<=' | '>' | '>=' | '==' | '!='
					| '<<' | '>>'
					| '&' | '^' | '|'
					| '&&' | '||'
					) a=expr b=expr)
	{
		$value = new ExprBin(op.Text, a, b);
	}
	| ^(op=('=' | '+=' | '-=' | '*=' | '/=' | '%=' | '&=' | '^=' | '|=' | '<<=' | '>>=') a=expr b=expr)
	{
		$value = new ExprBin(op.Text, a, b);
	}
	| ^(':=' a=expr list=expr_list)
	{
		System.Diagnostics.Debug.Assert(a is ExprConst);
		$value = new ExprAlloc("auto", new List<string> { ((ExprConst)a).Text }, list, true);
	}
	| ^(Expr_Bracket a=expr)
	{
		$value = new ExprBracket(a);
	}
	| ^(Expr_Suffix op=('++' | '--') a=expr)
	{
		$value = new ExprSuffix(op.Text, a);
	}
	| ^(Expr_Prefix op=('!' | '~' | '++' | '--' | '-' | '+' | '*' | '&') a=expr)
	{
		$value = new ExprPrefix(op.Text, a);
	}
	| text_ident = ident
	{
		$value = new ExprConst(text_ident, ConstType.Ident);
	}
	| text=(NUMBER | DOUBLE)
    {
        $value = new ExprConst(text.Text, ConstType.Number);
    }
	| text = STRING
	{
        $value = new ExprConst(text.Text, ConstType.String);
	}
	;
