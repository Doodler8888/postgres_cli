import db_connector/db_postgres, #[ os, ]# #[ strutils, ]# parseopt


# parse command-line arguments
var p = initOptParser()  # This sets up a parser to handle command-line arguments.
for kind, key, val in p.getopt():
  if kind == cmdArgument:  
    # connect to the database
    let conn = open(key, "user", "password", "localhost")

    # execute SQL query
    for row in conn.fastRows(sql"SELECT tablename FROM pg_tables WHERE schemaname = 'public';"):
      echo row[0]

    # close the connection
    conn.close()


# cmdArgument represents a command-line argument (e.g., a standalone value 
# that's not associated with an option flag). cmdArgument is an enum value 
# of CmdLineKind enumeration. Individaul enumeration values can be accessed 
# without needing to prefix them with the enum type name.


# kind: This represents the type of command-line argument. It's an enumeration value, and it could be one of the following:
#
# cmdEnd: Indicates the end of the command-line options.
# cmdShortOption: Indicates a short option (e.g., -a).
# cmdLongOption: Indicates a long option (e.g., --option).
# cmdArgument: Indicates a non-option argument.
# key: This represents the actual option key or argument. For short and long options, this would be the name of the option (without the dashes). For a non-option argument, this would be the argument itself.
#
# val: This represents the value associated with an option if it has one. If an option has a value (e.g., --option=value), then val will contain that value. If the option does not have a value, val will be an empty string.
