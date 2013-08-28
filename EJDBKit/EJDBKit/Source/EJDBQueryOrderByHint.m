#import "EJDBQueryOrderByHint.h"

@implementation EJDBQueryOrderByHint

+ (EJDBQueryOrderByHint *)orderPath:(NSString *)path direction:(EJDBQuerySortOrder)sortOrder
{
    return [[EJDBQueryOrderByHint alloc]initWithPath:path sortOrder:sortOrder];
}

- (id)initWithPath:(NSString *)path sortOrder:(EJDBQuerySortOrder)sortOrder
{
    self = [super init];
    if (self)
    {
        _path = [path copy];
        _sortOrder = sortOrder;
    }
    return self;
}

@end
