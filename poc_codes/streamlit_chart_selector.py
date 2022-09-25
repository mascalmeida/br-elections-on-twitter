## Dash selector - ref: https://github.com/streamlit/example-app-commenting/blob/8b0fe724f8b6c688d9eeb72121a2c75dc42dad08/streamlit_app.py#L6
tb_profile_info = load_mysql_table("SELECT * FROM profile_info", init_conn())
all_screen_names = tb_profile_info.screen_name.unique()
screen_names = st.multiselect("Choose candidates to visualize", all_screen_names, all_screen_names[1:3])