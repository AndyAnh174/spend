# 📖 Hướng Dẫn Sử Dụng Dự Án Quản Lý Chi Tiêu Tích Hợp AI

## 🎯 Tổng Quan

Dự án này là một website quản lý chi tiêu và thu nhập cá nhân với tích hợp AI thông minh, sử dụng:
- **Frontend**: React + TypeScript + TailwindCSS
- **Backend**: Golang + Gin + MongoDB
- **AI Service**: Python + FastAPI + Ollama (deepseek-r1:8b)

## 🚀 Cài Đặt Nhanh

### Bước 1: Cài đặt các công cụ cần thiết

1. **Ollama** - AI Model Runner
   ```bash
   # Windows (PowerShell)
   winget install Ollama.Ollama
   
   # Hoặc tải từ: https://ollama.ai/download
   ```

2. **Docker** - Database
   ```bash
   # Windows
   winget install Docker.DockerDesktop
   ```

3. **Go** - Backend
   ```bash
   # Windows
   winget install GoLang.Go
   ```

4. **Node.js** - Frontend
   ```bash
   # Windows
   winget install OpenJS.NodeJS
   ```

5. **Python** - AI Service
   ```bash
   # Windows
   winget install Python.Python.3.11
   ```

### Bước 2: Setup dự án

```bash
# Clone dự án (nếu chưa có)
git clone <repository-url>
cd spend-for-andyanh

# Chạy script setup tự động
setup.bat
```

### Bước 3: Chạy dự án

```bash
# Chạy tất cả services
start.bat
```

## 🔧 Cấu Hình Chi Tiết

### Environment Variables

Tạo file `.env` trong thư mục gốc:

```env
# Backend
MONGODB_URI=mongodb://localhost:27017
JWT_SECRET=your-super-secret-jwt-key-2024
PORT=8080

# AI Service
OLLAMA_URL=http://localhost:11434
AI_MODEL=deepseek-r1:8b
BACKEND_URL=http://localhost:8080

# Frontend
REACT_APP_API_URL=http://localhost:8080
REACT_APP_AI_SERVICE_URL=http://localhost:8000
```

### Cấu trúc thư mục

```
spend-for-andyanh/
├── backend/                 # Golang backend
│   ├── main.go
│   ├── go.mod
│   ├── models/
│   ├── handlers/
│   └── middleware/
├── frontend/               # React frontend
│   ├── src/
│   ├── package.json
│   └── public/
├── ai-service/            # Python AI service
│   ├── main.py
│   ├── requirements.txt
│   └── venv/
├── rules/                 # Documentation
├── docker-compose.yml
├── setup.bat
├── start.bat
└── README.md
```

## 🤖 Tính Năng AI

### 1. Phân tích chi tiêu thông minh

AI sẽ phân tích:
- **Xu hướng chi tiêu**: Theo dõi mẫu chi tiêu theo thời gian
- **Phân loại tự động**: Nhận diện danh mục chi tiêu
- **Phát hiện bất thường**: Cảnh báo chi tiêu bất thường

### 2. Lời khuyên tài chính

AI đưa ra:
- **Khuyến nghị tiết kiệm**: Dựa trên thu nhập và chi tiêu
- **Cảnh báo rủi ro**: Khi chi tiêu vượt ngưỡng
- **Gợi ý đầu tư**: Cơ hội tăng thu nhập

### 3. Dự báo tài chính

- **Dự báo chi tiêu**: Dựa trên lịch sử
- **Kế hoạch ngân sách**: Tối ưu hóa chi tiêu
- **Mục tiêu tài chính**: Theo dõi tiến độ

## 📊 API Endpoints

### Authentication
```
POST /api/auth/register - Đăng ký tài khoản
POST /api/auth/login    - Đăng nhập
```

### Expenses
```
GET    /api/expenses      - Lấy danh sách chi tiêu
POST   /api/expenses      - Thêm chi tiêu mới
PUT    /api/expenses/:id  - Cập nhật chi tiêu
DELETE /api/expenses/:id  - Xóa chi tiêu
GET    /api/expenses/stats - Thống kê chi tiêu
```

### Income
```
GET    /api/income      - Lấy danh sách thu nhập
POST   /api/income      - Thêm thu nhập mới
PUT    /api/income/:id  - Cập nhật thu nhập
DELETE /api/income/:id  - Xóa thu nhập
GET    /api/income/stats - Thống kê thu nhập
```

### AI Analysis
```
POST /api/ai/analyze        - Phân tích chi tiêu với AI
GET  /api/ai/recommendations - Lời khuyên tài chính
POST /api/ai/forecast       - Dự báo chi tiêu
GET  /api/ai/insights       - Thông tin chi tiết
```

## 🎨 Giao Diện Người Dùng

### Trang chính
- **Dashboard**: Tổng quan tài chính
- **Chi tiêu**: Quản lý các khoản chi
- **Thu nhập**: Quản lý các nguồn thu
- **Báo cáo**: Thống kê và biểu đồ
- **AI Analysis**: Phân tích thông minh

### Tính năng UI
- **Responsive Design**: Tương thích mobile
- **Dark/Light Mode**: Chế độ tối/sáng
- **Real-time Updates**: Cập nhật real-time
- **Interactive Charts**: Biểu đồ tương tác

## 🔒 Bảo Mật

### Authentication
- **JWT Tokens**: Xác thực an toàn
- **Password Hashing**: Mã hóa mật khẩu với bcrypt
- **Session Management**: Quản lý phiên đăng nhập

### Data Protection
- **HTTPS**: Mã hóa dữ liệu truyền tải
- **Input Validation**: Kiểm tra đầu vào
- **SQL Injection Protection**: Bảo vệ CSRF

## 🐛 Troubleshooting

### Lỗi thường gặp

1. **Ollama không chạy**
   ```bash
   # Kiểm tra Ollama
   ollama --version
   
   # Khởi động lại
   ollama serve
   ```

2. **MongoDB không kết nối**
   ```bash
   # Kiểm tra Docker
   docker ps
   
   # Khởi động MongoDB
   docker run --rm -p 27017:27017 mongo:latest
   ```

3. **Port đã được sử dụng**
   ```bash
   # Kiểm tra port
   netstat -ano | findstr :8080
   
   # Thay đổi port trong .env
   PORT=8081
   ```

### Logs

- **Backend**: `backend/logs/`
- **Frontend**: Browser Console
- **AI Service**: Terminal output

## 📈 Monitoring

### Health Checks
```
GET /health - Backend health
GET /health - AI Service health
```

### Metrics
- **Response Time**: Thời gian phản hồi API
- **Error Rate**: Tỷ lệ lỗi
- **User Activity**: Hoạt động người dùng

## 🚀 Deployment

### Production Setup

1. **Environment**
   ```bash
   # Production variables
   NODE_ENV=production
   MONGODB_URI=mongodb://prod-server:27017
   JWT_SECRET=super-secret-production-key
   ```

2. **Build**
   ```bash
   # Frontend
   cd frontend
   npm run build
   
   # Backend
   cd backend
   go build -o main
   ```

3. **Docker**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

## 🤝 Đóng Góp

### Development Workflow

1. **Fork** dự án
2. **Create** feature branch
3. **Commit** changes
4. **Push** to branch
5. **Create** Pull Request

### Code Standards

- **Go**: `gofmt`, `golint`
- **JavaScript**: `eslint`, `prettier`
- **Python**: `black`, `flake8`

## 📞 Hỗ Trợ

### Liên hệ
- **Email**: support@spend-app.com
- **GitHub**: Issues page
- **Documentation**: Wiki

### Resources
- [API Documentation](docs/api.md)
- [Database Schema](docs/schema.md)
- [AI Model Guide](docs/ai-guide.md)

---

**Lưu ý**: Đây là dự án demo, không nên sử dụng cho mục đích thương mại mà không có kiểm tra bảo mật đầy đủ.
