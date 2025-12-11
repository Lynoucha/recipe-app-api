FROM python:3.12-alpine3.21
LABEL maintainer="lynabouzouita.com"

ENV PYTHONUNBUFFERED=1
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app
EXPOSE 8000

ARG DEV=false

# install runtime packages + build deps temporarily
RUN apk add --update --no-cache \
        git \
        bash \
        ca-certificates \
        build-base \
        postgresql-dev \
        musl-dev \
    && python -m venv /py \
    && /py/bin/pip install --upgrade pip setuptools wheel \
    && /py/bin/pip install -r /tmp/requirements.txt \
    && if [ "$DEV" = "true" ] ; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi \
    && rm -rf /tmp/* \
    && apk del build-base musl-dev postgresql-dev \
    && adduser --disabled-password --no-create-home django-user

ENV PATH="/py/bin:$PATH"
USER django-user
