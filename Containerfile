FROM alpine/helm:3.16

WORKDIR /app

RUN apk upgrade --no-cache && apk add bash jq curl ca-certificates

COPY ./migrate-charts.sh .

ENTRYPOINT ["./migrate-charts.sh"]