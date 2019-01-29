FROM golang:1.10-alpine as builder

# Setup
RUN mkdir /app
WORKDIR /app

# Add libraries
RUN apk add --no-cache git && \
  go get "github.com/namsral/flag" && \
  go get "github.com/sirupsen/logrus" && \
  apk del git

# Copy & build
ADD . /app/
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /traefik-forward-auth .

# Copy into scratch container
FROM alpine:3.8
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /traefik-forward-auth ./
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
