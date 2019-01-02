FROM python:3.7.2

WORKDIR /usr/src/app

COPY Pipfile ./
COPY Pipfile.lock ./

RUN pip install pipenv
RUN pipenv install --system

COPY . .