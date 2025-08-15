package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	client *mongo.Client
	db     *mongo.Database
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// Connect to MongoDB
	connectDB()

	// Initialize Gin router
	r := gin.Default()

	// CORS configuration
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://localhost:3000", "http://127.0.0.1:3000"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Accept", "Authorization"}
	config.AllowCredentials = true
	r.Use(cors.New(config))

	// API routes
	api := r.Group("/api")
	{
		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/register", registerHandler)
			auth.POST("/login", loginHandler)
		}

		// Protected routes
		protected := api.Group("/")
		protected.Use(authMiddleware())
		{
			// Expenses routes
			expenses := protected.Group("/expenses")
			{
				expenses.GET("/", getExpenses)
				expenses.POST("/", createExpense)
				expenses.PUT("/:id", updateExpense)
				expenses.DELETE("/:id", deleteExpense)
				expenses.GET("/stats", getExpenseStats)
			}

			// Income routes
			income := protected.Group("/income")
			{
				income.GET("/", getIncome)
				income.POST("/", createIncome)
				income.PUT("/:id", updateIncome)
				income.DELETE("/:id", deleteIncome)
				income.GET("/stats", getIncomeStats)
			}

			// Dashboard routes
			dashboard := protected.Group("/dashboard")
			{
				dashboard.GET("/", getDashboardData)
				dashboard.GET("/summary", getFinancialSummary)
			}

			// AI Analysis routes
			ai := protected.Group("/ai")
			{
				ai.POST("/analyze", analyzeExpenses)
				ai.GET("/recommendations", getRecommendations)
				ai.POST("/forecast", forecastExpenses)
				ai.GET("/insights", getFinancialInsights)
			}
		}
	}

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"message": "Spend Management API is running",
			"time":    time.Now().Format(time.RFC3339),
		})
	})

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func connectDB() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	mongoURI := os.Getenv("MONGODB_URI")
	if mongoURI == "" {
		mongoURI = "mongodb://localhost:27017"
	}

	clientOptions := options.Client().ApplyURI(mongoURI)
	var err error
	client, err = mongo.Connect(ctx, clientOptions)
	if err != nil {
		log.Fatal("Failed to connect to MongoDB:", err)
	}

	// Ping the database
	err = client.Ping(ctx, nil)
	if err != nil {
		log.Fatal("Failed to ping MongoDB:", err)
	}

	db = client.Database("spend_db")
	log.Println("Connected to MongoDB successfully")
}

// Graceful shutdown
func cleanup() {
	if client != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := client.Disconnect(ctx); err != nil {
			log.Println("Error disconnecting from MongoDB:", err)
		}
	}
}
