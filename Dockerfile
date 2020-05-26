FROM ruby:2.7-alpine

RUN addgroup -g 1000 -S appgroup \
  && adduser -u 1000 -S appuser -G appgroup

WORKDIR /app

COPY bin/ ./bin
COPY lib/ ./lib

USER 1000

ENTRYPOINT ["ruby", "bin/enforce-repository-settings"]
