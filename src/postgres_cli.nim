import db_connector/db_postgres, parseopt, std/terminal, procs

var
  database = ""
  user = ""
  password = readPasswordFromStdin("Enter the password: ")
  activeFlag = false
  replaceFlag = false
  argCount = 0

let getActiveDatabases = sql"SELECT DISTINCT datname FROM pg_stat_activity;"

var p = initOptParser()  # This sets up a parser to handle command-line arguments.
for kind, key, val in p.getopt():
  if kind == cmdArgument and user == "":
    user = key
  elif kind == cmdShortOption and key == "d":
    database = val
  elif kind == cmdLongOption and key == "active":
    activeFlag = true
  elif kind == cmdLongOption and key == "replace":
    replaceFlag = true
  inc argCount

# echo "User: ", user
# echo "Database: ", database

if database != "" and user != "":
  let conn = open("localhost", user, password, database)

  if activeFlag:
    for row in conn.fastRows(getActiveDatabases):
      echo row[0]

  if replaceFlag:
    replaceTable(conn)
  
  if argCount == 2:
    for row in conn.fastRows(sql"SELECT tablename FROM pg_tables WHERE schemaname = 'public';"):
      echo row[0]

  # close the connection
  conn.close()
else:
  echo "Missing necessary information to connect to the database."


# cmdArgument represents a command-line argument (e.g., a standalone value 
# that's not associated with an option flag). cmdArgument is an enum value 
# of CmdLineKind enumeration. Individaul enumeration values can be accessed 
# without needing to prefix them with the enum type name.
# ---
# ---
# kind: This represents the type of command-line argument. It's an enumeration value, and it could be one of the following:
#
# cmdEnd: Indicates the end of the command-line options.
# cmdShortOption: Indicates a short option (e.g., -a).
# cmdLongOption: Indicates a long option (e.g., --option).
# cmdArgument: Indicates a non-option argument.
# key: This represents the actual option key or argument. For short and long options, this would be the name of the option (without the dashes). For a non-option argument, this would be the argument itself.
#
# val: This represents the value associated with an option if it has one. If an option has a value (e.g., --option=value), then val will contain that value. If the option does not have a value, val will be an empty string.
# ---
# ---
# When i use 'split' delimiter, the delimiter itself is not included.
# ---
# ---
# i can't use let to create the 'success' varible because it can throw an exception.
# ---
# ---
# notin operator is a specific operator used to check for the absence of a substring within a string. It's not the same as combining not and in. The notin operator is more efficient because it performs the operation in a single step, as opposed to evaluating in and then negating it with not.
#
# So, instead of writing:
# if command.strip() != "" and not ("--" in command):

# You can write:
# if command.strip() != "" and "--" notin command:
