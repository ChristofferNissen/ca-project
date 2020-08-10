FROM python:3
COPY requirements.txt /
COPY app/ /app/
COPY *.py /
RUN python3 -m pip install -r requirements.txt
ENTRYPOINT ["python3",  "run.py"]
