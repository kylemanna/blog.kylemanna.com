FROM ruby:2.7 as builder

# Throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./
RUN rake build

FROM caddy:2

COPY --from=builder /usr/src/app/_site /srv
COPY ./Caddyfile /etc/caddy/Caddyfile
