#import <Foundation/Foundation.h>

typedef enum {
    EJDBQuerySortDesc = -1,
    EJDBQuerySortAsc = 1
} EJDBQuerySortOrder;

@interface EJDBQueryOrderByHint : NSObject
@property (copy,nonatomic) NSString *path;
@property (assign,nonatomic) EJDBQuerySortOrder sortOrder;
+ (EJDBQueryOrderByHint *)orderPath:(NSString *)path direction:(EJDBQuerySortOrder)sortOrder;
- (id)initWithPath:(NSString *)path sortOrder:(EJDBQuerySortOrder)sortOrder;
@end
