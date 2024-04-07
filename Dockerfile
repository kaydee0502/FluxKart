FROM ruby:2.7-alpine3.12
RUN apk update
RUN apk add \
  build-base \
  bash \
  mariadb-dev \
  tzdata \
  git \
  libsodium \
  gcompat

WORKDIR /app

RUN gem install bundler -v 2.4
COPY ./Gemfile  ./
COPY ./Gemfile.lock ./

RUN bundle lock --add-platform x86_64-linux
RUN bundle install
COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
