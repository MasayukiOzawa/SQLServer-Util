from revoscalepy import rx_lin_mod, rx_serialize_model, rx_summary
import pandas as pd
import pyodbc
import os

conn_str = 'Driver=SQL Server;Server=<Server Name>;Database=MLDB;Uid=<User Name>;Pwd=<Password>;'
cnxn = pyodbc.connect(conn_str)
cnxn.setencoding("utf-8")
inputsql = 'select "RentalCount", "Year", "Month", "Day", "WeekDay", "Snow", "Holiday", "FWeekDay" from dbo.rental_data where Year < 2015'
rental_train_data = pd.read_sql(inputsql, cnxn)

rental_train_data["Holiday"] = rental_train_data["Holiday"].astype("category")
rental_train_data["Snow"] = rental_train_data["Snow"].astype("category")
rental_train_data["WeekDay"] = rental_train_data["WeekDay"].astype("category")

linmod_model = rx_lin_mod("RentalCount ~ Month + Day + WeekDay + Snow + Holiday", data = rental_train_data)
trained_model = rx_serialize_model(linmod_model, realtime_scoring_only = True)

print(rx_summary("RentalCount ~ Month + Day + WeekDay + Snow + Holiday", rental_train_data))

# Dump learned model to file
with open(r'c:\model\trained_model.pickle', mode='wb') as f:
    f.write(trained_model)

# Dump learned model to Table
cursor=cnxn.cursor()
cursor.execute(\
'''
MERGE rental_models AS target
USING (SELECT ? as model_name) AS source
ON(target.model_name = source.model_name)
WHEN MATCHED THEN UPDATE SET native_model = ?
WHEN NOT MATCHED BY TARGET THEN INSERT (model_name, lang, native_model) VALUES(?,?,?);
''', \
("linear_model", trained_model, "linear_model", "Python", trained_model))
cnxn.commit()
