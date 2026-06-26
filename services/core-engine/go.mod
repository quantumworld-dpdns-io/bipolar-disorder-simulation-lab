module quantumsynapse

go 1.22

require (
    github.com/99designs/gqlgen v0.17.31
	github.com/gorilla/mux v1.8.1
    "github.com/gorilla/handlers v1.5.1"
    "github.com/go-chi/chi/v5 v5.7.0"
    "github.com/gocraft/work v0.5.1"
    "github.com/go-sql-driver/mysql v1.8.0"
    "github.com/golang-jwt/jwt/v4 v4.5.0"
    "go.opentelemetry.io/otel v0.31.0"
    "go.opentelemetry.io/otel/trace v0.31.0"
    "github.com/elastic/go-elasticsearch v7.17.0"
    "github.com/spf13/viper v1.19.0"
    "github.com/gin-contrib/cors v1.0.2"
    "github.com/joho/godotenv v1.5.1"
)

replace github.com/gocraft/work => github.com/gocraft/work v0.5.1