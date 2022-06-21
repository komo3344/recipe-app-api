FROM python:3.9-alpine3.13
LABEL maintainer="wnsdud3119.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
# 대부분의 경우 Docker로 작업할 때  가상환경을 사용할 필요가 없다고 생각하지만
# 실제 기본 이미지에 일부 파이썬 종속성이 있는 경우가 있을 수 있습니다.
# 즉, 프로젝트에 대한 python 종속성과 충돌할 수 있습니다.
# 따라서 이러한 일이 발생하지 않고 위험을 줄이는 방법은 가상 환경을 만드는 것입니다.
# Docker 이미지는 실제로 그렇게 많은 오버헤드를 발생시키지 않습니다.
# 따라서 실제로 그렇게 많은 단점은 없지만 충돌하는 종속성으로부터 보호합니다.
RUN python -m venv /py && \
  /py/bin/pip install --upgrade pip && \
  apk add --update --no-cache postgresql-client && \
  apk add --upgrade --no-cache --virtual .tmp-build-deps \
  build-base postgresql-dev musl-dev && \
  /py/bin/pip install -r /tmp/requirements.txt && \
  if [ $DEV = "true" ]; \
  then /py/bin/pip install -r /tmp/requirements.dev.txt; \
  fi && \
  rm -rf /tmp && \
  apk del .tmp-build-deps && \
  adduser \
  --disabled-password \
  --no-create-home \
  django-user

# 이미지 내부의 환경변수가 업데이트되고 경로 환경 변수가 업데이트 됩니다.
ENV PATH="/py/bin:$PATH"

USER django-user