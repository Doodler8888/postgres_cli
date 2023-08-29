import db_connector/db_postgres, parseopt, std/terminal, strutils, os, osproc

var
  database = ""
  user = ""
  password = readPasswordFromStdin("Enter the password: ")
  activeFlag = false
  replaceFlag = false
  argCount = 0

let getActiveDatabases = sql"SELECT DISTINCT datname FROM pg_stat_activity;"

# parse command-line arguments
var p = initOptParser()  # This sets up a parser to handle command-line arguments.
for kind, key, val in p.getopt():
  if kind == cmdArgument and user == "":  # cmdArgument is used for arguments that are attached to an option, like botdb in -d botdb. Positional arguments like bot in your command line input are classified as cmdEnd. 
    user = key
    # inc argCount
  elif kind == cmdShortOption and key == "d":
    database = val
    # inc argCount
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
    echo "Enter the name of the table you want to replace:"
    let oldTable = readLine(stdin)
    echo "Enter path to the new table:"
    let sqlFilePath = readLine(stdin)

    if fileExists(sqlFilePath):
      try:
        conn.exec(sql"DROP TABLE ", oldTable)
        let fileContent = readFile(sqlFilePath)
        let commands = fileContent.split(";")
        for command in commands:
          if command.strip() != "":
            conn.exec(sql(command))
        conn.close()
      except:
        echo "An error occurred while replacing the table."
  
  if argCount == 2:
    for row in conn.fastRows(sql"SELECT tablename FROM pg_tables;"):
      echo row[0]

  # close the connection
  conn.close()
else:
  echo "Missing necessary information to connect to the database."


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

# i can't use let to create the 'success' varible because it can throw an exception.
