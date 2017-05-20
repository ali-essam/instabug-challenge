FROM ruby:2.4-slim

# RUN apk update && apk --update add postgresql-client
#
# RUN apk --update add --virtual build_deps \
#     build-base ruby-dev libc-dev linux-headers \
#     openssl-dev postgresql-dev libxml2-dev libxslt-dev

RUN apt-get update
RUN apt-get install -y --no-install-recommends postgresql-client \
  build-essential patch ruby-dev zlib1g-dev liblzma-dev
RUN apt-get -y --no-install-recommends install libpq-dev
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .

# RUN apk del build_deps

ENV RAILS_ENV production

EXPOSE 3000
# ENTRYPOINT ["sh", "./init.sh"]
# CMD ["rails", "server", "-b", "0.0.0.0"]
