package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// User represents a user in the system
type User struct {
	ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Username  string             `json:"username" bson:"username" binding:"required"`
	Email     string             `json:"email" bson:"email" binding:"required,email"`
	Password  string             `json:"password" bson:"password" binding:"required,min=6"`
	CreatedAt time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt time.Time          `json:"updated_at" bson:"updated_at"`
}

// UserResponse represents user data without password
type UserResponse struct {
	ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Username  string             `json:"username" bson:"username"`
	Email     string             `json:"email" bson:"email"`
	CreatedAt time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt time.Time          `json:"updated_at" bson:"updated_at"`
}

// LoginRequest represents login request
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse represents login response with JWT token
type LoginResponse struct {
	Token string       `json:"token"`
	User  UserResponse `json:"user"`
}

// Expense represents an expense entry
type Expense struct {
	ID          primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	UserID      primitive.ObjectID `json:"user_id" bson:"user_id"`
	Amount      float64            `json:"amount" bson:"amount" binding:"required,gt=0"`
	Category    string             `json:"category" bson:"category" binding:"required"`
	Description string             `json:"description" bson:"description"`
	Date        time.Time          `json:"date" bson:"date" binding:"required"`
	CreatedAt   time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt   time.Time          `json:"updated_at" bson:"updated_at"`
}

// Income represents an income entry
type Income struct {
	ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	UserID    primitive.ObjectID `json:"user_id" bson:"user_id"`
	Amount    float64            `json:"amount" bson:"amount" binding:"required,gt=0"`
	Source    string             `json:"source" bson:"source" binding:"required"`
	Date      time.Time          `json:"date" bson:"date" binding:"required"`
	CreatedAt time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt time.Time          `json:"updated_at" bson:"updated_at"`
}

// DashboardData represents dashboard summary data
type DashboardData struct {
	TotalExpenses    float64            `json:"total_expenses"`
	TotalIncome      float64            `json:"total_income"`
	NetAmount        float64            `json:"net_amount"`
	ExpensesByCategory map[string]float64 `json:"expenses_by_category"`
	IncomeBySource    map[string]float64 `json:"income_by_source"`
	MonthlyTrend      []MonthlyData      `json:"monthly_trend"`
	RecentExpenses    []Expense          `json:"recent_expenses"`
	RecentIncome      []Income           `json:"recent_income"`
}

// MonthlyData represents monthly financial data
type MonthlyData struct {
	Month   string  `json:"month"`
	Expenses float64 `json:"expenses"`
	Income   float64 `json:"income"`
	Net      float64 `json:"net"`
}

// AIAnalysisRequest represents AI analysis request
type AIAnalysisRequest struct {
	UserID    primitive.ObjectID `json:"user_id" bson:"user_id"`
	TimeRange string             `json:"time_range"` // "week", "month", "quarter", "year"
	AnalysisType string          `json:"analysis_type"` // "spending_pattern", "savings_advice", "budget_optimization"
}

// AIAnalysisResponse represents AI analysis response
type AIAnalysisResponse struct {
	Analysis     string                 `json:"analysis"`
	Insights     []string               `json:"insights"`
	Recommendations []Recommendation    `json:"recommendations"`
	RiskFactors  []string               `json:"risk_factors"`
	Opportunities []string              `json:"opportunities"`
	Score        float64                `json:"score"` // Financial health score 0-100
	Data         map[string]interface{} `json:"data"`
}

// Recommendation represents a financial recommendation
type Recommendation struct {
	Type        string  `json:"type"` // "savings", "spending_reduction", "investment", "budget_adjustment"
	Title       string  `json:"title"`
	Description string  `json:"description"`
	Impact      string  `json:"impact"` // "high", "medium", "low"
	Priority    int     `json:"priority"`
	PotentialSavings float64 `json:"potential_savings,omitempty"`
}

// FinancialInsight represents a financial insight
type FinancialInsight struct {
	ID          primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	UserID      primitive.ObjectID `json:"user_id" bson:"user_id"`
	Type        string             `json:"type" bson:"type"`
	Title       string             `json:"title" bson:"title"`
	Description string             `json:"description" bson:"description"`
	Data        map[string]interface{} `json:"data" bson:"data"`
	CreatedAt   time.Time          `json:"created_at" bson:"created_at"`
}

// ExpenseStats represents expense statistics
type ExpenseStats struct {
	TotalAmount     float64            `json:"total_amount"`
	AverageAmount   float64            `json:"average_amount"`
	CategoryBreakdown map[string]float64 `json:"category_breakdown"`
	MonthlyTrend    []MonthlyData      `json:"monthly_trend"`
	TopCategories   []CategoryStat     `json:"top_categories"`
}

// IncomeStats represents income statistics
type IncomeStats struct {
	TotalAmount   float64            `json:"total_amount"`
	AverageAmount float64            `json:"average_amount"`
	SourceBreakdown map[string]float64 `json:"source_breakdown"`
	MonthlyTrend  []MonthlyData      `json:"monthly_trend"`
	TopSources    []SourceStat       `json:"top_sources"`
}

// CategoryStat represents category statistics
type CategoryStat struct {
	Category string  `json:"category"`
	Amount   float64 `json:"amount"`
	Count    int     `json:"count"`
	Percentage float64 `json:"percentage"`
}

// SourceStat represents source statistics
type SourceStat struct {
	Source     string  `json:"source"`
	Amount     float64 `json:"amount"`
	Count      int     `json:"count"`
	Percentage float64 `json:"percentage"`
}

// ForecastRequest represents forecast request
type ForecastRequest struct {
	UserID     primitive.ObjectID `json:"user_id" bson:"user_id"`
	Months     int                `json:"months" binding:"required,min=1,max=12"`
	IncludeAI  bool               `json:"include_ai"`
}

// ForecastResponse represents forecast response
type ForecastResponse struct {
	Forecast   []MonthlyData      `json:"forecast"`
	Confidence float64            `json:"confidence"`
	Factors    []string           `json:"factors"`
	Warnings   []string           `json:"warnings"`
}
