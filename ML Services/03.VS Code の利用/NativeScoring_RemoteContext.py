'''
# https://microsoft.github.io/sql-ml-tutorials/python/rentalprediction/
# https://docs.microsoft.com/en-us/machine-learning-server/install/python-libraries-interpreter
[Environment]::SetEnvironmentVariable('UID', '<SQL Login>', 'User')
[Environment]::SetEnvironmentVariable('SQLPass', '<SQL Login Password>', 'User')
'''
import os

from revoscalepy import rx_lin_mod, rx_serialize_model, rx_dtree, rx_summary

from revoscalepy import RxComputeContext, RxInSqlServer, RxSqlServerData
from revoscalepy import RxLocalSeq, rx_get_compute_context, rx_set_compute_context
from revoscalepy import rx_import
from pandas import Categorical
import pandas as pd
import pyodbc

model_type = "linear"
conn_str = 'Driver=SQL Server;Server=<Server Name>;Database=MLDB;Uid=<User Name>;Pwd=<Password>;'
inputsql = 'select "RentalCount", "Year", "Month", "Day", "WeekDay", "Snow", "Holiday", "FWeekDay" from dbo.rental_data where Year < 2015'

cc = RxInSqlServer(
     connection_string = conn_str,
     num_tasks = 1,
     auto_cleanup = False
)
local_cc = RxLocalSeq()
previous_cc = rx_set_compute_context(cc)
rx_get_compute_context()

column_info = {
         "Year" : { "type" : "integer" },
         "Month" : { "type" : "integer" },
         "Day" : { "type" : "integer" },
         "RentalCount" : { "type" : "integer" },
         "WeekDay" : {
             "type" : "factor",
             "levels" : ["1", "2", "3", "4", "5", "6", "7"]
         },
         "Holiday" : {
             "type" : "factor",
             "levels" : ["1", "0"]
         },
         "Snow" : {
             "type" : "factor",
             "levels" : ["1", "0"]
         }
     }
data_source = RxSqlServerData(sql_query=inputsql, connection_string=conn_str, column_info=column_info)

linmod_model = rx_lin_mod("RentalCount ~ Month + Day + WeekDay + Snow + Holiday", data = data_source, computeContext = cc)
trained_model = rx_serialize_model(linmod_model, realtime_scoring_only = True)

with open(r'c:\temp\trained_model.pickle', mode='wb') as f:
    f.write(trained_model)

print(rx_summary("RentalCount ~ Month + Day + WeekDay + Snow + Holiday", data_source))


cnxn = pyodbc.connect(conn_str)
cursor=cnxn.cursor()
cursor.execute("INSERT INTO rental_models(model_name, lang, native_model) VALUES(?, ?, ?)", ("linear_model", "Python", trained_model))
cnxn.commit()