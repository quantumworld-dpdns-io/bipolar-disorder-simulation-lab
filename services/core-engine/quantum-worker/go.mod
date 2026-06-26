# services/core-engine/quantum-worker/go.mod
gomodule quantumsynapse/quantum-worker

go 1.22

require (
	github.com/gin-gonic/gin v1.9.1
	github.com/go-redis/redis/v8 v8.0.0
	github.com/golang-jwt/jwt/v4 v4.5.0
	github.com/gocraft/work v0.5.1
	github.com/elastic/go-elasticsearch v7.17.0
	github.com/spf13/viper v1.19.0
	github.com/gin-contrib/cors v1.0.2
	github.com/joho/godotenv v1.5.1
	go.opentelemetry.io/otel v0.31.0
	go.opentelemetry.io/otel/trace v0.31.0
)
