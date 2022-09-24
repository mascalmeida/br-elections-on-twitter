# IMPORT PACKAGES
## streamlit package
import streamlit as st
## data manipulation
import pandas as pd
## date transformation
from datetime import datetime, timedelta
## working with mysql
#import pymysql
import mysql.connector

# FUNCTIONS ------------------------------------------------------------------

# Initialize connection with MySQL database
def init_conn():
    return mysql.connector.connect(**st.secrets["mysql"])

## Get table from MySQL
def load_mysql_table(query, conn):
    df = pd.read_sql(query, conn)
    conn.close()
    return(df)

# DATA MANIPULATIONS ----------------------------------------------------------
df = load_mysql_table("SELECT * FROM vw_last_update", init_conn())

# DASHBOARD -------------------------------------------------------------------
# Last valid date
st.write(':arrows_counterclockwise: Last update: ' + str(df.iloc[0,0]))
st.write(':soon: Next update: ' + str((df.iloc[0,0] + timedelta(days=1)).date()) + ' at 12PM')

## Dash title
st.title('Twitter & Brazilian Elections')