import os
import argparse
import pandas as pd
import numpy as np
import urllib.parse
from sqlalchemy import create_engine


parser = argparse.ArgumentParser(description='Export trace data to csv')

# required params 
parser.add_argument('--export_path', required=True, 
                   help='location to export to')
# .. eg \\csnyfs01.creditsights.net\Research\QuantitativeStrategy\data-warehouse-exports
parser.add_argument('--db_user',  required=True,
                   help='database username for db connection string')
# .. eg 'quant'
parser.add_argument('--db_pass',  required=True,
                   help='database password for db connection string')

# params you may want to tweak if you copy this script
parser.add_argument('--export_file', default='trace_one_monthly.csv', 
                   help='csv to export to')

# params you will probably just leave with defaults except in dev, maybe
parser.add_argument('--debug_only', default=False,
                   help='set to true to do a quick test instead of full query')
parser.add_argument('--db_server', default='csnydata01.creditsights.net\csnext',
                   help='database server for db connection string')
parser.add_argument('--db_database', default='Trace', 
                   help='database to connect to in db connection string')

args = parser.parse_args()


db_connection_string = ("Uid=%s;Pwd=%s;Driver={SQL Server Native Client 11.0};" \
						+ "Initial Catalog=%s;Server=%s;Database=%s;")\
						%(args.db_user, args.db_pass, args.db_database, args.db_server, args.db_database)

# Setup database connection
print("connecting to db..")
params = urllib.parse.quote_plus(db_connection_string)
sqlalchemy = create_engine("mssql+pyodbc:///?odbc_connect=%s" % params)

# select trailing 1 month from trace
sql = """SELECT """ \
  + ("TOP 100 " if args.debug_only else "") \
  + """ +  [cusip]
	  , evt.[REQ_SYM] req_sym
      ,[SEQUENCE] sequence
      ,[SYMBOL] symbol
      ,[COMPOSITE_EXCHANGE] composite_exchange
      ,[LAST_1] last_1
      ,[LAST_VOL_1] last_vol_1
      ,[CUM_VOL] cum_vol
      ,[VWAP] vwap
      ,[OPEN_1] open_1
      ,[HIGH_1] high_1
      ,[LOW_1] low_1
      ,[TRADE_CONDITIONS] trade_conditions
	  -- FIXME:
	  -- hello future maintainer person - yes please, please make 
	  -- these conversions go away by refactoring the db to store with relevant data types
	  , convert(date, convert(nvarchar, [TRANSACTION_DATE_1])) as transaction_date_1
	  , convert(time, STUFF(STUFF(right('000000'+ convert(varchar, [TRANSACTION_TIME_1]), 6),3,0,':'),6,0,':'))  transaction_time_1
      ,[EXCHANGE_SHORT] exchange_short
      ,[EXCHANGE_LONG] exchange_long 
      ,evt.[Date] [date]
  FROM [event] evt
	JOIN [tickmapping] ticks on  ticks.REQ_SYM = evt.REQ_SYM
  WHERE
    convert(datetime, convert(nvarchar, [TRANSACTION_DATE_1])) > dateadd(month, -1, getdate())
-- Nice to have but much slower till they add some indexes    
--  ORDER BY  
--  	transaction_date_1 desc, sequence desc 
"""

print("querying db with:")
print(sql)


df = pd.read_sql_query(sql, sqlalchemy)

# <- It is not necessary to load data into a dataframe. In fact it would be much faster
# and more memory efficient to just serialize the data straight out to csv as it 
# arrives. However, loading it into a dataframe here so we have things ready (and libraries
# installed) for more complex data buffing rules to be added here if need be -> 

export_file_path = os.path.join(args.export_path, args.export_file)
print("exporting to csv " + export_file_path)
df.to_csv(export_file_path,mode = 'w', index=False)