FROM alpine/helm

RUN apk upgrade --no-cache && apk add bash

ENTRYPOINT ["./migrate-charts"]