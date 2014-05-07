#import <PEGKit/PKParser.h>

enum {
    PEGKIT_TOKEN_KIND_SYMBOL_TITLE = 14,
    PEGKIT_TOKEN_KIND_SEMANTICPREDICATE,
    PEGKIT_TOKEN_KIND_PIPE,
    PEGKIT_TOKEN_KIND_AFTERKEY,
    PEGKIT_TOKEN_KIND_CLOSE_CURLY,
    PEGKIT_TOKEN_KIND_TILDE,
    PEGKIT_TOKEN_KIND_EMAIL_TITLE,
    PEGKIT_TOKEN_KIND_COMMENT_TITLE,
    PEGKIT_TOKEN_KIND_DISCARD,
    PEGKIT_TOKEN_KIND_INITKEY,
    PEGKIT_TOKEN_KIND_HKEY,
    PEGKIT_TOKEN_KIND_NUMBER_TITLE,
    PEGKIT_TOKEN_KIND_ANY_TITLE,
    PEGKIT_TOKEN_KIND_SEMI_COLON,
    PEGKIT_TOKEN_KIND_S_TITLE,
    PEGKIT_TOKEN_KIND_ACTION,
    PEGKIT_TOKEN_KIND_EQUALS,
    PEGKIT_TOKEN_KIND_AMPERSAND,
    PEGKIT_TOKEN_KIND_PATTERNNOOPTS,
    PEGKIT_TOKEN_KIND_MKEY,
    PEGKIT_TOKEN_KIND_PHRASEQUESTION,
    PEGKIT_TOKEN_KIND_PATTERNIGNORECASE,
    PEGKIT_TOKEN_KIND_OPEN_PAREN,
    PEGKIT_TOKEN_KIND_AT,
    PEGKIT_TOKEN_KIND_QUOTEDSTRING_TITLE,
    PEGKIT_TOKEN_KIND_BEFOREKEY,
    PEGKIT_TOKEN_KIND_EOF_TITLE,
    PEGKIT_TOKEN_KIND_CLOSE_PAREN,
    PEGKIT_TOKEN_KIND_PHRASESTAR,
    PEGKIT_TOKEN_KIND_URL_TITLE,
    PEGKIT_TOKEN_KIND_EMPTY_TITLE,
    PEGKIT_TOKEN_KIND_PHRASEPLUS,
    PEGKIT_TOKEN_KIND_LETTER_TITLE,
    PEGKIT_TOKEN_KIND_OPEN_BRACKET,
    PEGKIT_TOKEN_KIND_COMMA,
    PEGKIT_TOKEN_KIND_DEALLOCKEY,
    PEGKIT_TOKEN_KIND_MINUS,
    PEGKIT_TOKEN_KIND_WORD_TITLE,
    PEGKIT_TOKEN_KIND_CLOSE_BRACKET,
    PEGKIT_TOKEN_KIND_CHAR_TITLE,
    PEGKIT_TOKEN_KIND_SPECIFICCHAR_TITLE,
    PEGKIT_TOKEN_KIND_EXTENSIONKEY,
    PEGKIT_TOKEN_KIND_DIGIT_TITLE,
    PEGKIT_TOKEN_KIND_INTERFACEKEY,
    PEGKIT_TOKEN_KIND_IMPLEMENTATIONKEY,
    PEGKIT_TOKEN_KIND_IVARSKEY,
    PEGKIT_TOKEN_KIND_DELIMOPEN,
};

@interface PEGKitParser : PKParser

@end

