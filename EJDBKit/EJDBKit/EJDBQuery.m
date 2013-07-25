#import "EJDBQuery.h"
#import "EJDBCollection.h"

@interface EJDBQuery ()
@property (strong,nonatomic) EJDBCollection *collection;
@end

@implementation EJDBQuery

- (id)initWithEJQuery:(EJQ *)query collection:(EJDBCollection *)collection
{
    self = [super init];
    if (self)
    {
        _ejQuery = query;
        _collection = collection;
    }
    return self;
}

- (void)execute
{
    uint32_t count = 0;
    TCLIST *r = ejdbqryexecute(_collection.collection, _ejQuery, &count, 0, NULL);
    for (int i = 0; i < TCLISTNUM(r);i++)
    {
       void *p =  TCLISTVALPTR(r, 0);
       bson_print_raw(p, 3);
    }
    ejdbquerydel(_ejQuery);
}

@end
