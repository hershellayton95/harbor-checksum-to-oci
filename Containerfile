FROM alpine/helm

WORKDIR /app

RUN apk upgrade --no-cache && apk add bash jq curl

COPY navarcos-ca.crt /usr/local/share/ca-certificates/navarcos-ca.crt
RUN update-ca-certificates --fresh > /dev/null

COPY ./migrate-charts.sh .

ENTRYPOINT ["./migrate-charts.sh"]