FROM ruby:3.1
WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .
EXPOSE 3099
ENV PUMA_BIND="tcp://0.0.0.0:3099"
CMD ["ruby", "app.rb"]
