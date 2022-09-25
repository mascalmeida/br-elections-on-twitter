# IMPORT PACKAGES
## streamlit package
import streamlit as st
## data manipulation
import pandas as pd
import numpy as np
## date transformation
from datetime import datetime, timedelta
## working with mysql
import mysql.connector

# FUNCTIONS ------------------------------------------------------------------

## Initialize connection with MySQL database
def init_conn():
    return mysql.connector.connect(**st.secrets["mysql"])

## Get table from MySQL
def load_mysql_table(query, conn):
    df = pd.read_sql(query, conn)
    conn.close()
    return(df)

## Adds empty lines to the Streamlit app.
def space(num_lines=1):
    """Adds empty lines to the Streamlit app."""
    for _ in range(num_lines):
        st.write("")

# DATA MANIPULATIONS ----------------------------------------------------------


# DASHBOARD -------------------------------------------------------------------

## Get last update view from MySQL
vw_last_update = load_mysql_table("SELECT * FROM vw_last_update", init_conn())
## Last and Next valid date
st.write(':arrows_counterclockwise: Last update: ' + str(vw_last_update.iloc[0,0]))
st.write(':soon: Next update: ' + str((vw_last_update.iloc[0,0] + timedelta(days=1)).date()) + ' at 12PM')

## Dash title
st.title('Twitter & Brazilian Elections')

## All mentions graph
tb_profile_mentions = load_mysql_table("SELECT * FROM profile_mentions", init_conn())
chart_columns = ["end", "@cirogomes_mentions", "@jairbolsonaro_mentions", "@LulaOficial_mentions", "@simonetebetbr_mentions"]
chart_data = tb_profile_mentions.loc[:, chart_columns]
st.line_chart(chart_data, x="end", y=chart_columns[1:], use_container_width=True)

space(1)