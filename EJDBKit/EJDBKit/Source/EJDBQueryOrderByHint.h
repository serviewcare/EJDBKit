#import <Foundation/Foundation.h>

typedef enum {
    /** Descending order. */
    EJDBQuerySortDesc = -1,
    /** Ascending order. */
    EJDBQuerySortAsc = 1
} EJDBQuerySortOrder;

/**
 This class serves as a wrapper for the sort order hint that can be given to a query.
 It takes a field path and a sort order as properties.
*/
@interface EJDBQueryOrderByHint : NSObject
/* The field path of the order by hint. */
@property (copy,nonatomic) NSString *path;
/* The sort order of the hint.*/
@property (assign,nonatomic) EJDBQuerySortOrder sortOrder;
/** 
 Convenience class method to create a sort order hint.
 @param path - The field path of the order by hint.
 @param sortOrder - The direction of the sort order. The value can be descending or ascending.
 @since - v.0.3.0
*/
+ (EJDBQueryOrderByHint *)orderPath:(NSString *)path direction:(EJDBQuerySortOrder)sortOrder;

- (id)initWithPath:(NSString *)path sortOrder:(EJDBQuerySortOrder)sortOrder;
@end
