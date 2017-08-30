FROM ruby:2.2

ADD . /

RUN bundle install

CMD . ./envs && bundle exec ruby steggybot.rb
