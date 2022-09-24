# IMPORT PACKAGES
## streamlit package
import streamlit as st
## data manipulation
import pandas as pd
## loading data from python to sql database
import sqlalchemy as sa
from sqlalchemy import create_engine
## working with mysql
import pymysql
import mysql.connector
## hiding MySQL credentials - ref: https://youtu.be/CJjSOzb0IYs
import mysqlcredentials

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
st.write('Last update:', df.iloc[0,0])

## Dash title
st.title('Twitter & Brazilian Elections')






