'''
# https://microsoft.github.io/sql-ml-tutorials/python/rentalprediction/
# https://docs.microsoft.com/en-us/machine-learning-server/install/python-libraries-interpreter
[Environment]::SetEnvironmentVariable('UID', '<SQL Login>', 'User')
[Environment]::SetEnvironmentVariable('SQLPass', '<SQL Login Password>', 'User')
'''
import os

from revoscalepy import rx_lin_mod, rx_serialize_model, rx_dtree, rx_summary
from pandas import Categorical
import pandas as pd
import pyodbc

model_type = "linear"
conn_str = 'Driver=SQL Server;Server=<Server Name>;Database=MLDB;Uid=<User Name>;Pwd=<Password>;'
cnxn = pyodbc.connect(conn_str)
inputsql = 'select "RentalCount", "Year", "Month", "Day", "WeekDay", "Snow", "Holiday", "FWeekDay" from dbo.rental_data where Year < 2015'
rental_train_data = pd.read_sql(inputsql, cnxn)

# Used to sample data
# train = rental_train_data.sample(frac=0.8, random_state=1)
# test = rental_train_data.loc[~ rental_train_data.index.isin(train.index)]
# print("Train {0} / test {1}".format(len(train), len(test)))

rental_train_data["Holiday"] = rental_train_data["Holiday"].astype("category")
rental_train_data["Snow"] = rental_train_data["Snow"].astype("category")
rental_train_data["WeekDay"] = rental_train_data["WeekDay"].astype("category")

if model_type == "linear":
    linmod_model = rx_lin_mod("RentalCount ~ Month + Day + WeekDay + Snow + Holiday", data = rental_train_data)
    trained_model = rx_serialize_model(linmod_model, realtime_scoring_only = True)
if model_type == "dtree":
	dtree_model = rx_dtree("RentalCount ~ Month + Day + WeekDay + Snow + Holiday", data = rental_train_data)
	trained_model = rx_serialize_model(dtree_model, realtime_scoring_only = True)

print(rx_summary("~ Month + Day + WeekDay + Snow + Holiday", rental_train_data))

# Dump learned model to file
with open(r'c:\temp\trained_model.pickle', mode='wb') as f:
    f.write(trained_model)

cursor=cnxn.cursor()
cursor.execute("INSERT INTO rental_models(model_name, lang, native_model) VALUES(?, ?, ?)", (model_type + "_model", "Python", trained_model))
cnxn.commit()