FROM python:3.9
RUN mkdir /code
WORKDIR /code
ADD src/* /code/

RUN apt-get update && \
    apt-get install -y

RUN pip install -r /code/requirements.txt

EXPOSE 5000
CMD python3 main.py