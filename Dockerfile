FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copy dependency files
# COPY go.mod go.sum ./ # sum is only required when there is dependencies :P
COPY go.mod .
RUN go mod download

# Copy the source code
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server cmd/sacre-tech-go-super-power/main.go

FROM scratch
# Copy ssl certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/server /server

EXPOSE 8080
ENTRYPOINT [ "/server" ]