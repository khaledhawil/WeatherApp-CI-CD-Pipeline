# Build stage
FROM golang:alpine AS builder
WORKDIR /go/src/app
COPY . .
WORKDIR /go/src/app/main
RUN go get -v ./...
RUN go build -o /go/bin/app -v ./...

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /go/bin/app .
RUN chmod +x ./app
ENTRYPOINT ["./app"]
LABEL Name=auth Version=2.0.0
EXPOSE 8080
