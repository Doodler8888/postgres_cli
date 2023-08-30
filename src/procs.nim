import db_connector/db_postgres, strutils, os, strformat

proc replaceTable*(conn: DbConn) =
    echo "Enter the name of the table you want to replace:"
    let oldTable = readLine(stdin)
    echo "Enter path to the new table:"
    let sqlFilePath = readLine(stdin)

    if fileExists(sqlFilePath):
      try:
        conn.exec(sql("DROP TABLE " & oldTable))
        let fileContent = readFile(sqlFilePath)
        # echo "File content: ", fileContent
        let commands = fileContent.split(";")
        for command in commands:
          # echo "sql command: ", command
          if command.strip() != "" and "--" notin command:
            echo "command: ", command
            conn.exec(sql(command))
      except Exception:
        echo "An error occurred while replacing the table. ", getCurrentExceptionMsg()


proc showTable*(conn: DbConn) =
  echo "Enter the name of the table you want to look at:"
  let tableName = readLine(stdin)
  try:
    let query = "SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = '" & tableName & "';"
    echo "--------------------------------------------------------------"
    for row in conn.fastRows(sql(query)):
      echo fmt"{row[0]} ({row[1]})"
  except Exception:
    echo "An error occurred while looking at the table. ", getCurrentExceptionMsg()

