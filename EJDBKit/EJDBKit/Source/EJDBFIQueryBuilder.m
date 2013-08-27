#import "EJDBFIQueryBuilder.h"
#import "EJDBQueryOrderByHint.h"

@implementation EJDBFIQueryBuilder

- (id)initWithDictionary:(NSDictionary *)dict hints:(NSDictionary *)hints
{
    self = [super init];
    if (self)
    {
        _query = dict;
        _hints = hints;
    }
    return self;
}

+ (EJDBFIQueryBuilder *)build
{
   return [[EJDBFIQueryBuilder alloc]initWithDictionary:[NSDictionary dictionary] hints:[NSDictionary dictionary]];
}

- (PathValueBlock)match
{
    return ^(NSString *path,id obj) {
       NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [result setObject:obj forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:result hints:self.hints];
    };
}

- (PathValueBlock)notMatch
{
    return ^(NSString *path, id obj) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$not" toObject:obj] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (SubstringBlock)matchIgnoreCase
{
    return ^(NSString *path, NSString *substring) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$icase" toObject:substring] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (SubstringBlock)beginsWith
{
    return ^(NSString *path, NSString *substring) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$begin" toObject:substring] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (SubstringBlock)notBeginsWith
{
    return ^(NSString *path, NSString *substring) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        NSDictionary *begin = [self applyOperator:@"$begin" toObject:substring];
        [results setObject:[self applyOperator:@"$not" toObject:begin] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathNumberBlock)greaterThan
{
    return ^(NSString *path, NSNumber *number) {
       NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$gt" toObject:number] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathNumberBlock)greaterThanOrEqualTo
{
    return ^(NSString *path, NSNumber *number) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$gte" toObject:number] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathNumberBlock)lessThan
{
    return ^(NSString *path, NSNumber *number) {
       NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$lt" toObject:number] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathNumberBlock)lessThanOrEqualTo
{
    return ^(NSString *path, NSNumber *number) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$lte" toObject:number] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathValueBlock)between
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$bt" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathValueBlock)in
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$in" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathValueBlock)inIgnoreCase
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
      NSDictionary *in = [self applyOperator:@"$in" toObject:obj];
      [results setObject:[self applyOperator:@"$icase" toObject:in] forKey:path];
      return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathValueBlock)notIn
{
     return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$nin" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };   
}

- (PathValueBlock)notInIgnoreCase
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
      NSDictionary *inQuery = [self applyOperator:@"$nin" toObject:obj];
      [results setObject:[self applyOperator:@"$icase" toObject:inQuery] forKey:path];
      return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathBlock)exists
{
    return ^(NSString *path) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
      NSNumber *yes = [NSNumber numberWithBool:YES];
       [results setObject:[self applyOperator:@"$exists" toObject:yes] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathBlock)notExists
{
    return ^(NSString *path) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
      NSNumber *no = [NSNumber numberWithBool:NO];
       [results setObject:[self applyOperator:@"$exists" toObject:no] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathValueBlock)stringAllIn
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$strand" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathValueBlock)stringAnyIn
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$stror" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (PathValueBlock)elemsMatch
{
    return ^(NSString *path, EJDBFIQueryBuilder *builder) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$elemMatch" toObject:builder.query] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (AndOrJoinBlock)andJoin
{
    return ^(NSArray *subqueries) {
       NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       NSMutableArray *subqueriesArray = [NSMutableArray array];
       for (EJDBFIQueryBuilder *builder in subqueries)
       {
           [subqueriesArray addObject:builder.query];
       }
      [results setObject:[NSArray arrayWithArray:subqueriesArray] forKey:@"$and"];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (AndOrJoinBlock)orJoin
{
     return ^(NSArray *subqueries) {
       NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       NSMutableArray *subqueriesArray = [NSMutableArray array];
       for (EJDBFIQueryBuilder *builder in subqueries)
       {
           [subqueriesArray addObject:builder.query];
       }
      [results setObject:[NSArray arrayWithArray:subqueriesArray] forKey:@"$or"];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints];
    };
}

- (NumberBlock)maxRecords
{
    return ^(NSNumber *number) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.hints];
        [results setObject:number forKey:@"$max"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:[NSDictionary dictionaryWithDictionary:results]];
    };
}

- (NumberBlock)skipRecords
{
    return ^(NSNumber *number) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.hints];
        [results setObject:number forKey:@"$skip"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:[NSDictionary dictionaryWithDictionary:results]];
    };
}

- (ArrayBlock)onlyFields
{
    return ^(NSArray *fields) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.hints];
        NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionary];
        for (NSString *field in fields)
        {
            [fieldsDictionary setObject:@YES forKey:field];
        }
        [results setObject:[NSDictionary dictionaryWithDictionary:fieldsDictionary] forKey:@"$fields"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:[NSDictionary dictionaryWithDictionary:results]];
    };
}

- (ArrayBlock)orderBy
{
    return ^(NSArray *fields) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.hints];
        NSMutableDictionary *orderByDictionary = [NSMutableDictionary dictionary];
        for (EJDBQueryOrderByHint *orderByHint in fields)
        {
            [orderByDictionary setObject:[NSNumber numberWithInt:orderByHint.sortOrder]
                                  forKey:orderByHint.path];
        }
        [results setObject:[NSDictionary dictionaryWithDictionary:orderByDictionary] forKey:@"$orderby"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:[NSDictionary dictionaryWithDictionary:results]];
    };
}

- (NSDictionary *)applyOperator:(NSString *)operator toObject:(id)object
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [results setObject:object forKey:operator];
    return [NSDictionary dictionaryWithDictionary:results];
}

@end