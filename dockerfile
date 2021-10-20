FROM ruby:3.0.2-alpine3.13

RUN gem install bundler

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh && \
    apk add --update make && \
    apk add --update gcc && \
    apk add libc-dev

#COPY . /tmp/code
#RUN cd /tmp/code

CMD [ "/bin/sh" ]