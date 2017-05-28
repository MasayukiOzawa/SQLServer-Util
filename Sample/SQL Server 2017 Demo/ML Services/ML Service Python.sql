exec sp_execute_external_script 
@language =N'Python', 
@script=N'OutputDataSet = InputDataSet', 
@input_data_1 = N'SELECT name,type_desc FROM sys.objects' 

exec sp_execute_external_script  
@language =N'Python',  
@script=N'
import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
					
import tensorflow as tf
hello = tf.constant("Hello, TensorFlow!")
sess = tf.Session()
print(sess.run(hello))
'
