# chef-tools

CHEF-TOOLS is a set of scripts to encapsulate basic knife commands.

# Summary

This set of scripts encapsulates basic knife commands to search, bootstrap and deploy on nodes. You can specify by environment, zone or name. It accepts the same regex rules as KNIFE.

# Features

* Bootstrap nodes

* Deploy on nodes
  * Filter by name
  * Filter by environment
  * Filter by zone

# Instalation

Use the install.sh script to automaticaly add the script to your "PATH"

# Usage

## Bootstrap

``` Bash
Usage: chef-tools bootstrap [-e|--environment <environment_name>]

"-e | --environment <environment_name> [Optional]"
"-n | --node-list <node_list> [Optional]"
"-d | --domain <domain> [Optional]"
"-y | --yes [Optional]"
"-h | --help"
```

## Deploy

``` Bash
Usage: chef-tools deploy -e|--environment <environment_name>

"-e | --environment <environment_name>"
"Required"
"-n | --node-list <node_list>"
"Optional"
"-z | --zone <zone>"
"Optional"
"-r | --role <role>"
"Optional"
"-p | --parallel <true|false>"
"Optional"
"-o | --override-run-list <Array with roles/recipes>"
"Optional"
"-i | --include-patch-repo <true|false>"
"Optional"
"-h | --help"
```

# Examples

## Bootstrap

``` Bash
"chef-tools bootstrap -e Dev11 --yes"
"chef-tools bootstrap -n \"webserver01 webserver02\" --yes"
"chef-tools bootstrap -n \"webserver01 webserver02\" --domain your.custom.domain --yes"
"chef-tools bootstrap --help"
```

## Deploy

``` Bash
"chef-tools deploy -e Dev11 -z US [-p true]"
"chef-tools deploy -n \"webserver01 webserver03\" [-p true]"
"chef-tools deploy --help"
```
