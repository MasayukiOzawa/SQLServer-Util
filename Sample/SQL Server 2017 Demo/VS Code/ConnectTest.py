import pymssql

conn = pymssql.connect(server='127.0.0.1', user='sa', password='<Password>')
cursor = conn.cursor()
cursor.execute("SELECT @@version")
row = cursor.fetchone()
while row:
    print("%s" % (row[0]))
    row = cursor.fetchone()
    