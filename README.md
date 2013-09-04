EJDBKit Framework
=================

The EJDBKit framework is an attempt at wrapping the [EJDB](https://github.com/Softmotions/ejdb) C library made by the folks over at [Softmotions](http://softmotions.com) into a convenient and easy to use Objective-C framework. For more information on EJDB check out [ejdb.org](http://ejdb.org).

Current Status
=================

Sep 4, 2013 - v0.3.1
- Bumped ejdb submodule to ejdb release v1.1.23

Aug 29, 2013 - v0.3.0
- Added import/export functionality to EJDBDatabase class.
- Added new EJDBQueryBuilder and EJDBFIQueryBuilder classes for programmatic query building.
- Bumped ejdb submodule to ejdb release v1.1.22


I will try to make future releases as painless as possible (minimal code changes on your end, if any)
but I can't guarantee complete shelter from pain until at least version 1.0. :)
If there are any drastic changes before a 1.0, I will provide transition guides (and/or mark portions of code deprecated if feasible) to make any necessary changes as smooth as possible. I also promise to
not remove deprecated code until the next non-maintenance release (0.2,0.3,etc).
Having said that, I encourage you to, at least, start experimenting with the framework today
(looking for bugs,checking performance,etc), in other words, throw everything you've got at it!
If you find any showstoppers, serious bugs or anything else noteworthy (not feature requests)
please do let me know! One more thing...enjoy!!!!


Feature Requests
====================

Missing something? Do you think the framework could use even more love? Feel free to make an issue
detailing what you'd like to see! :) If the request is sane, useful and doesn't unnecessarily complicate
the codebase then it has a very good chance of making it into a future release!
Please, before making a feature request, try to always keep in mind simplicity/usefulness.The
framework can't possibly be everything to everyone and I have no intention of making it into one. 


Usage
==================

**EJDBDatabase** - This is the object that holds the underlying database.

Example:

Open a database:

```objc
 EJDBDatabase *db = [[EJDBDatabase alloc] initWithPath:@"some/path" 
                                          dbFileName:@"foo.db"];
 [db openWithError:NULL];
```

Create a collection (via db):

```objc
 EJDBCollection *collection = [db ensureCollectionWithName:@"foo" error:NULL];

```

Or (via collection object itself)

```objc

//Want to make a new collection?

EJDBCollection *collection = [[EJDBCollection alloc]initWithName:@"foo" db:db];
// This creates the collection for you if it doesn't already exist
[collection openWithError:NULL];

//Already have one that you want to retrieve?
EJDBCollection *collection = [EJDBCollection collectionWithName:@"foo" db:db];
//No need to call openWithError

```

**EJDBCollection** - This is the object through which you can save objects to the database, i.e. the collection in the database.

Using your newly created collection you can now
insert an object into the collection via a standard NSDictionary instance:

```objc
NSDictionary *dict1 = @{@"first name" : @"foo",@"last name" : @"bar"};
[collection saveObject:dict];
```

Or even your own custom NSObject subclass that adopts the BSONArchiving protocol (see below for more details):

```objc
// It doth conform to BSONArchiving thus it shall be saved!

CustomArchivableClass *obj = [[CustomArchivableClass alloc init]];
[collection saveObject:obj];
```

Or...multiple objects at once:

```objc
[collection saveObjects:@[dict1,dict2,...]];
```

Want to do stuff in a transaction? Here you go:

```objc

NSError *error;
[_db transactionInCollection:collection error:&error
                      transaction:^BOOL(EJDBCollection *collection,NSError **error) {
   
   [collection saveObjects@[dict1,dict2,dict3]];
   // Whatever else you need to do.
   //...
   //return YES to commit the transaction or NO to abort it.
   return YES;
}];

```

Querying a collection (via db):

```objc
//Find all objects whose first name starts with 'f'
NSDictionary *theQuery = @{@"first name":@{@"$begin":@"f"}};

NSArray *results = [_db findObjectsWithQuery:theQuery 
						inCollection:collection error:NULL];
//results will contain dict1 as created in the preceeding section.
```

Or (via a query object itself)

```objc

//collection instance created elsewhere
EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:collection 
                      query:@{@"first name":@{@"$begin":@"f"}}];
NSArrary *results = [query fetchObjects];
// Sometime later, somewhere you can re-fetch.
[query fetchObjects];
```

Querying with hints (order by,etc)

```objc
NSDictionary *theQuery = @{@"first name":@{@"$begin":@"f"}};

//Only return the 'first name' column, analagous to select `first name` from foo
NSDictionary *hints = @{@"$fields":@{@"first name": @1};

NSArray *results = [_db findObjectsWithQuery:theQuery
						hints:hints
						inCollection:collection error:NULL];
```

Want to fetch a specific object without querying? No problem (you do need to supply a valid OID though):

```objc

NSDictionary *dictionary = [collection fetchObjectWithOID:@"SomeValidOID"];
```

Or, if you want to fetch a custom object (remember the same rules apply when fetching a custom class):

```objc
MyCustomClass *obj = [collection fetchObjectWithOID:@"SomeValidOID"];
```

Don't need your object anymore? Go ahead and remove it then:

```objc
[collection removeObject:obj];
```

Or remove it by supplying an OID:

```objc
[collection removeObjectWithOID:@"SomeValidOID"];
```

Don't need your collection anymore? Just remove it like so:

```objc
[db removeCollectionWithName:@"foo"];
```


Check out the [wiki](https://github.com/johnnyd/EJDBKit/wiki) for more information


Building/Installing
=====================

Take a look at the [wiki](https://github.com/johnnyd/EJDBKit/wiki).


API Documentation
======================
You can build doxygen documentation with the Doxyfile included in the project.
It will create a docs directory with the generated HTML inside.

iOS versions supported
=======================

The tcejdb library is built with a base of iOS 5.0 and deployment target of iOS 6.1.
I can't vouch for earlier versions and I'm not really concerned either (come on folks we'll have 7.0 soon)!

Collaboration
==============
As always, the more folks working on this, the better,stronger and (hopefully)faster the framework
will become. So contact me at darkstar.jd AT gmail if you're interested!

License
==============
LGPL (same as ejdb). Any other source according to its corresponding license.