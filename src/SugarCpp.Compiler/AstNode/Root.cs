﻿using Antlr4.StringTemplate;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SugarCpp.Compiler
{
    public class Root : AstNode
    {
        public List<AstNode> List = new List<AstNode>();

        public override Template Accept(Visitor visitor)
        {
            return visitor.Visit(this);
        }
    }
}
