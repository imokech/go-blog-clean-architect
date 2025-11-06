FROM golang:1.23-bookworm AS base

# Development Stage
FROM base AS development

WORKDIR /app

RUN apt-get update && apt-get install -y git
RUN go install github.com/cosmtrek/air@v1.49.0

COPY go.mod go.sum ./

RUN go mod download

COPY .air.toml ./
COPY . .

CMD ["air"]

# Builder Stage
FROM base AS builder

WORKDIR /build

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o go-blog

# Production Stage
FROM scratch AS production

WORKDIR /prod

COPY --from=builder /build/go-blog ./

EXPOSE 8000

CMD ["/prod/go-blog"]