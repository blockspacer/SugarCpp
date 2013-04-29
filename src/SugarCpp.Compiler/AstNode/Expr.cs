﻿using Antlr4.StringTemplate;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SugarCpp.Compiler
{
    public abstract class Expr : Stmt
    {
    }

    public class ExprAssign : Expr
    {
        public Expr Left, Right;

        public ExprAssign(Expr left, Expr right)
        {
            this.Left = left;
            this.Right = right;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprBin : Expr
    {
        public Expr Left, Right;
        public string Op;

        public ExprBin(string op, Expr left, Expr right)
        {
            this.Op = op;
            this.Left = left;
            this.Right = right;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprPrefix : Expr
    {
        public Expr Expr;
        public string Op;

        public ExprPrefix(string op, Expr expr)
        {
            this.Expr = expr;
            this.Op = op;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprSuffix : Expr
    {
        public Expr Expr;
        public string Op;

        public ExprSuffix(string op, Expr expr)
        {
            this.Expr = expr;
            this.Op = op;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprDict : Expr
    {
        public Expr Expr;
        public Expr Index;

        public ExprDict(Expr expr, Expr index)
        {
            this.Expr = expr;
            this.Index = index;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprCall : Expr
    {
        public Expr Expr;
        public List<Expr> Args = new List<Expr>();

        public ExprCall(Expr expr, List<Expr> args)
        {
            this.Expr = expr;
            this.Args = args;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprLambda : Expr
    {
        public Expr Expr;
        public List<Stmt> Args = new List<Stmt>();

        public ExprLambda(Expr expr, List<Stmt> args)
        {
            this.Expr = expr;
            if (args != null)
            {
                this.Args = args;
            }
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprAccess : Expr
    {
        public Expr Expr;
        public string Op;
        public string Name;

        public ExprAccess(Expr expr, string op, string name)
        {
            this.Expr = expr;
            this.Op = op;
            this.Name = name;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprNew : Expr
    {
        public List<Expr> Ranges = new List<Expr>();
        public string ElemType;

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprCond : Expr
    {
        public Expr Cond;
        public Expr Expr1;
        public Expr Expr2;

        public ExprCond(Expr cond, Expr expr1, Expr expr2)
        {
            this.Cond = cond;
            this.Expr1 = expr1;
            this.Expr2 = expr2;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprTuple : Expr
    {
        public List<Expr> ExprList = new List<Expr>();

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprReturn : Expr
    {
        public Expr Expr;

        public ExprReturn(Expr expr)
        {
            this.Expr = expr;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprBlock : Expr
    {
        public List<Stmt> StmtList = new List<Stmt>();

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }

    public class ExprConst : Expr
    {
        public string Text;

        public ExprConst(string text)
        {
            this.Text = text;
        }

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }
}