FROM python:3
COPY requirements.txt /
RUN python3 -m pip install -r requirements.txt
COPY app/ /app/
COPY *.py /
COPY app.db /
ENTRYPOINT ["python3"]
CMD [ "run.py" ]
