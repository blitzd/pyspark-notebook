import os
import sys

spark_home = os.environ.get('SPARK_HOME', None)

# check if it exists
if not spark_home:
    raise ValueError('SPARK_HOME environment variable is not set')

# check if it is a directory
if not os.path.isdir(spark_home):
    raise ValueError('SPARK_HOME environment variable is not a directory')

# check if we can find the python sub-directory
if not os.path.isdir(os.path.join(spark_home, 'python')):
    raise ValueError('SPARK_HOME directory does not contain python')

sys.path.insert(0, os.path.join(spark_home, 'python'))

# check if we can find the py4j zip file
if not os.path.exists(os.path.join(spark_home, 'python/lib/py4j-0.8.2.1-src.zip')):
    raise ValueError('Could not find the py4j library - \
            maybe your version number is different?(Looking for 0.8.2.1)')

sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.8.2.1-src.zip'))

with open(os.path.join(spark_home, 'python/pyspark/shell.py')) as f:
    code = compile(f.read(), os.path.join(spark_home, 'python/pyspark/shell.py'), 'exec')
    exec(code)
