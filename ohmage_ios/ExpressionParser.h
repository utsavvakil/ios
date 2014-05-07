#import <PEGKit/PKParser.h>

enum {
    EXPRESSIONPARSER_TOKEN_KIND_GE = 14,
    EXPRESSIONPARSER_TOKEN_KIND_COMMA,
    EXPRESSIONPARSER_TOKEN_KIND_OR,
    EXPRESSIONPARSER_TOKEN_KIND_LT,
    EXPRESSIONPARSER_TOKEN_KIND_LE,
    EXPRESSIONPARSER_TOKEN_KIND_EQ,
    EXPRESSIONPARSER_TOKEN_KIND_DOT,
    EXPRESSIONPARSER_TOKEN_KIND_GT,
    EXPRESSIONPARSER_TOKEN_KIND_OPENPAREN,
    EXPRESSIONPARSER_TOKEN_KIND_YES,
    EXPRESSIONPARSER_TOKEN_KIND_NO,
    EXPRESSIONPARSER_TOKEN_KIND_CLOSEPAREN,
    EXPRESSIONPARSER_TOKEN_KIND_NE,
    EXPRESSIONPARSER_TOKEN_KIND_AND,
};

@interface ExpressionParser : PKParser

@end

