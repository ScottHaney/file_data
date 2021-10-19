FROM ruby:3.0.2-alpine3.13

RUN gem install rspec

COPY . /tmp/code

CMD [ "/bin/sh" ]