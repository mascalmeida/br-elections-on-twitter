# Define the python image
FROM public.ecr.aws/lambda/python:3.9

# Copy function code and auxiliar files
COPY main_etl_code.py ${LAMBDA_TASK_ROOT}
COPY apikeys.py ${LAMBDA_TASK_ROOT}
COPY mysqlcredentials.py ${LAMBDA_TASK_ROOT}

# install python packages
RUN pip3 install tweepy \
  && pip3 install pandas \
  && pip3 install SQLAlchemy \
  && pip3 install pymysql

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "main_etl_code.run_etl" ]