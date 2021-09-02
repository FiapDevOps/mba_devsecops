FROM python:3

WORKDIR /usr/src/app

COPY build/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY build/ .

CMD [ "python", "./app.py" ]