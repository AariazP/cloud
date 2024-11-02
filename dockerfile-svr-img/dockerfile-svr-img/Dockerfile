# Fase de construcción
FROM golang:1.20 AS builder
WORKDIR /app
COPY ./WebAppGO/ /app
RUN go build -o srvimg ./server/Server.go

FROM debian:stable-slim
WORKDIR /app
COPY --from=builder /app/srvimg /app/srvimg
COPY ./WebAppGO/static /app/static
EXPOSE 7900
CMD ["/app/srvimg", "7900"]

