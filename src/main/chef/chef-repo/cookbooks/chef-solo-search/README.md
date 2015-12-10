# chef-solo-search

[![Build Status](https://travis-ci.org/edelight/chef-solo-search.png?branch=master)](https://travis-ci.org/edelight/chef-solo-search)

Chef-solo-search is a cookbook library that adds data bag search powers
to Chef Solo. Data bag support was added to Chef Solo by Chef 0.10.4.
Please see *Supported queries* for a list of query types which are supported.

## Requirements

* ruby >= 1.8
* ruby-chef >= 0.10.4

## Installation

Install this cookbook into your Chef repository using your favorite cookbook
management tool ([Librarian][], [Berkshelf][], knife...).

In Chef 11, you must either add this to the run list of the nodes where it's
used or include it as a dependency in the recipes that use it. See [changes in
Chef 11][].

Now you have to make sure chef-solo knows about data bags, therefore add

```ruby
data_bag_path "#{node_work_path}/data_bags"
```

to the config file of chef-solo (defaults to /etc/chef/solo.rb).

The same for your roles, add

```ruby
role_path "#{node_work_path}/roles"
```

To support encrypted data bags, add

    encrypted_data_bag_secret "path_to_data_bag_secret"

## Supported queries

The search methods supports a basic sub-set of the [Lucene][] query language.

### General queries:

```ruby
# all items in ':users'
search(:users, "*:*")
search(:users)
search(:users, nil)

# all items from ':users' which have a 'username' attribute
search(:users, "username:*")
search(:users, "username:[* TO *]")

# all items from ':users' which don't have a 'username' attribute
search(:users, "(NOT username:*)")
search(:users, "(NOT username:[* TO *])")
```

### Queries on attributes with string values:

```ruby
# all items from ':users' with username equals 'speedy'
search(:users, "username:speedy")

# all items from ':users' with username is unequal to 'speedy'
search(:users, "NOT username:speedy")

# all items which 'username'-value begins with 'spe'
search(:users, "username:spe*")
```

### Queries on attributes with array values:

```ruby
# all items which 'children' attribute contains 'tom'
search(:users, "children:tom")

# all items which have at least one element in 'children' which starts with 't'
search(:users, "children:t*")
```

### Queries on attributes with boolean values:

```ruby
search(:users, "married:true")
```

### Queries in attributes with integer values:

```ruby
search(:users, "age:35")
```

### OR conditions in queries:

```ruby
search(:users, "age:42 OR age:22")
```

### AND conditions in queries:

```ruby
search(:users, "married:true AND age:35")
```

### NOT condition in queries:

```ruby
search(:users, "children:tom AND (NOT gender:female)")
```

### More complex queries:

```ruby
search(:users, "children:tom AND (NOT gender:female) AND age:42")
```


## Supported Objects

The search methods have support for 'roles', 'nodes' and 'databags'.

### Roles

You can use the standard role objects in JSON form and put them into your role path

```javascript
{
  "name": "monitoring",
  "default_attributes": { },
  "override_attributes": { },
  "json_class": "Chef::Role",
  "description": "This is just a monitoring role, no big deal.",
  "run_list": [
  ],
  "chef_type": "role"
}
```

You can also use ruby formatted roles and put them in your role path.
The one proviso being that the filename must match the rolename

```ruby
name "other"
description "AN Other Role"
run_list []
```

### Databags

You can use the standard databag objects in JSON form.

```javascript
{
  "id": "my-ssh",
  "hostgroup_name": "all",
  "command_line": "$USER1$/check_ssh $HOSTADDRESS$"
}
```

### Nodes

Nodes are injected through a databag called 'node'.  Create a databag called
'node' and put your JSON files there.

You can use the standard node objects in JSON form.

```javascript
{
  "id": "vagrant",
  "name": "vagrant-vm",
  "chef_environment": "_default",
  "json_class": "Chef::Node",
  "automatic": {
    "hostname": "vagrant.vm",
    "os": "centos"
  },
  "normal": {
  },
  "chef_type": "node",
  "default": {
  },
  "override": {
  },
  "run_list": [
    "role[monitoring]"
  ]
}
```

## Running tests

Running tests is as simple as:

```sh
% rake test && kitchen test
```

[Librarian]:https://github.com/applicationsonline/librarian-chef
[Berkshelf]:https://github.com/RiotGames/berkshelf
[changes in Chef 11]:http://docs.opscode.com/breaking_changes_chef_11.html#non-recipe-file-evaluation-includes-dependencies
[Lucene]:http://lucene.apache.org/
