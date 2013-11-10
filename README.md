Baggage
-------

Baggage is a gem/bundler/rake/rails-like system for Bash.

For a really quick overview go to [baggage.io](http://baggage.io).

You can use it to build standalone applications, or to build libraries (called bags) that can be used in other Baggage projects.

Installation
------------

Simply run this on your terminal.

    curl http://get.baggage.io | bash

Creating a project
------------------

The process for building application and bag projects is the same. In fact, the same project can be both an application and a library.

    $ baggage new my_project
    $ cd my_project
    my_project$ tree
    .
    ├── Baggage
    ├── bags
    ├── bin
    │   └── calc_total
    ├── ext
    ├── lib
    │   └── example.bash
    ├── out
    └── test
        └── example.bats

A new project comes with some sample files, as used here [baggage.io](http://baggage.io). 

In brief, it creates:

 * Baggage file - Contains metadata and specified dependencies
 * bags directory - Bags we depend on are installed here
 * bin directory - 

The Baggage file
----------------

All Baggage projects need a Baggage file the their root directory. This file contains metadata about the project and specifies libraries that it depends on.

Here is an example file

    name        "calc_total"
    version     "0.1.0"
    description "Add your description"

    # We really want this ext so we can use it to test
    # bags as we install them. Remove it at your peril.
    
    bag core https://github.com/zeroXten/baggage-core.git
    ext bats https://github.com/sstephenson/bats.git
    
    # Add your bags here

The meaning of the attributes is quite obvious, but you are not allowed spaces in the name.

We can also see two other interesting things, namely the "bag" and "ext" methods. The bag method states that we require the specified bag (a Baggage library) and the ext method states that we require an external library or script.

Bags
----

Bags are 

External scripts
----------------
