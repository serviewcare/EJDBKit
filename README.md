EJDBKit Framework
=================

The EJDBKit framework is an attempt at wrapping the [EJDB](https://github.com/Softmotions/ejdb) C library made by the folks over at [Softmotions](http://softmotions.com) into a convenient and easy to use Objective-C framework. For more information on EJDB check out [ejdb.org](http://ejdb.org).

Current Status
=================

It is definitely in a useable state but I would wait a bit before using it
in a production environment as it may change quite a bit before 
a first "stable" release(0.1.0).
Having said that, I plan on actively working on this project until, 
at the very least, I'm satisfied it is a complete and correct implementation.

Usage
==================

**EJDBDatabase** - This is the object you will likely use most often. It allows you to open/close a database and create/remove/query collections.

Example:

Open a database:

```objc
 EJDBDatabase *db = [[EJDBDatabase alloc] initWithPath:@"some/path" 
                                          dbFileName:@"foo.db"];
 [db openWithError:NULL];
```

Create a collection:

```objc
 EJDBCollection *collection = [db ensureCollectionWithName:@"foo" error:NULL];

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

Querying a collection:

```objc
//Find all objects whose first name starts with 'f'
NSDictionary *theQuery = @{@"first name":@{@"$begin":@"f"}};

NSArray *results = [_db findObjectsWithQuery:theQuery 
						inCollection:collection error:NULL];
//results will contain dict1 as created in the preceeding section.
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