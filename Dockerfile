# Build stage
FROM golang:1.17-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
ARG GO_FILE
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ${GO_FILE}

# Production stage
FROM scratch

# Copy the binary from builder
COPY --from=builder /app/main .

# Copy SSL certificates for HTTPS requests
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Command to run
ENTRYPOINT ["./main"]