# 💰 Website Quản Lý Chi Tiêu & Thu Nhập Cá Nhân - Tích Hợp AI

## 🎯 Mục tiêu
Website giúp người dùng theo dõi chi tiêu và thu nhập cá nhân với AI phân tích thông minh, đưa ra lời khuyên tài chính.

## ✨ Tính năng chính

### 🔐 Xác thực & Bảo mật
- Đăng ký/Đăng nhập với JWT
- Mã hóa mật khẩu với bcrypt
- Bảo mật dữ liệu người dùng

### 📊 Quản lý tài chính
- Nhập chi tiêu theo danh mục
- Nhập thu nhập từ nhiều nguồn
- Biểu đồ thống kê trực quan
- Báo cáo chi tiết theo thời gian

### 🤖 AI Phân tích thông minh
- Phân tích xu hướng chi tiêu
- Đưa ra lời khuyên tiết kiệm
- Cảnh báo chi tiêu vượt ngưỡng
- Gợi ý mục tiêu tài chính

## 🛠️ Công nghệ sử dụng

### Frontend
- **React** + **TypeScript**
- **TailwindCSS** cho UI
- **Chart.js** cho biểu đồ
- **Axios** cho API calls

### Backend
- **Golang** + **Gin framework**
- **MongoDB** database
- **JWT** authentication
- **Remote Ollama AI** integration

### AI Model
- **deepseek-r1:8b** (có thinking capability)
- **Remote Server**: [http://olla.hcmutertic.com](http://olla.hcmutertic.com)
- Phân tích chi tiêu thông minh
- Gợi ý tài chính cá nhân hóa

## 📁 Cấu trúc dự án

```
spend-for-andyanh/
├── frontend/                 # React frontend
├── backend/                  # Golang backend
├── ai-service/              # AI integration service
├── docker-compose.yml       # Docker setup
├── .env                     # Environment variables
├── setup-remote.bat         # Setup with remote Ollama
├── test-ollama.bat          # Test remote connection
└── README.md
```

## 🚀 Cách chạy dự án

### 1. Kiểm tra Remote Ollama Server
```bash
# Test kết nối với remote server
test-ollama.bat

# Hoặc chạy test Python
cd ai-service
python test_connection.py
```

### 2. Setup dự án (Remote Ollama)
```bash
# Setup với remote Ollama server
setup-remote.bat
```

### 3. Chạy dự án
```bash
# Chạy tất cả services
start.bat
```

## 🔧 Cấu hình

### Environment Variables (.env)
```env
# Backend
MONGODB_URI=mongodb://localhost:27017
JWT_SECRET=your-secret-key
PORT=8080

# AI Service - Remote Ollama
OLLAMA_URL=http://olla.hcmutertic.com
AI_MODEL=deepseek-r1:8b
BACKEND_URL=http://localhost:8080

# Frontend
REACT_APP_API_URL=http://localhost:8080
REACT_APP_AI_SERVICE_URL=http://localhost:8000
```

## 📊 API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập

### Expenses
- `GET /api/expenses` - Lấy danh sách chi tiêu
- `POST /api/expenses` - Thêm chi tiêu
- `PUT /api/expenses/:id` - Sửa chi tiêu
- `DELETE /api/expenses/:id` - Xóa chi tiêu

### Income
- `GET /api/income` - Lấy danh sách thu nhập
- `POST /api/income` - Thêm thu nhập
- `PUT /api/income/:id` - Sửa thu nhập
- `DELETE /api/income/:id` - Xóa thu nhập

### AI Analysis
- `POST /api/ai/analyze` - Phân tích chi tiêu
- `GET /api/ai/recommendations` - Lời khuyên tài chính
- `POST /api/ai/forecast` - Dự báo chi tiêu

## 🤖 Tính năng AI

### 1. Phân tích chi tiêu thông minh
- Nhận diện xu hướng chi tiêu
- Phát hiện chi tiêu bất thường
- Phân loại chi tiêu tự động

### 2. Lời khuyên tài chính
- Gợi ý cách tiết kiệm
- Đề xuất cắt giảm chi tiêu
- Tư vấn đầu tư phù hợp

### 3. Dự báo và cảnh báo
- Dự báo chi tiêu tương lai
- Cảnh báo vượt ngân sách
- Nhắc nhở mục tiêu tài chính

## 🌐 Remote Ollama Server

Dự án sử dụng remote Ollama server tại [http://olla.hcmutertic.com](http://olla.hcmutertic.com)

### Ưu điểm:
- ✅ Không cần cài đặt Ollama local
- ✅ Không cần pull model (đã có sẵn)
- ✅ Tiết kiệm tài nguyên máy tính
- ✅ Dễ dàng scale và maintain

### Kiểm tra kết nối:
```bash
# Test cơ bản
curl http://olla.hcmutertic.com/api/tags

# Test AI generation
curl -X POST http://olla.hcmutertic.com/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-r1:8b","prompt":"Hello","stream":false}'
```

## 📈 Roadmap

- [x] Setup project structure
- [x] Basic CRUD operations
- [x] AI integration with remote server
- [ ] Advanced analytics
- [ ] Mobile app
- [ ] Multi-language support

## 🤝 Đóng góp

1. Fork dự án
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## 📄 License

MIT License - xem file LICENSE để biết thêm chi tiết.
