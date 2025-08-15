# Prompt xây dựng Website Quản Lý Chi Tiêu và Thu Nhập Cá Nhân

## Mục tiêu của Web:
- Xây dựng một website giúp người dùng theo dõi chi tiêu và thu nhập cá nhân hàng tháng.
- Cung cấp các tính năng như:
  - Nhập liệu chi tiêu: các loại chi phí sinh hoạt, mua sắm, ăn uống, v.v.
  - Nhập liệu thu nhập: tiền lương, thu nhập từ công việc phụ, lợi nhuận đầu tư, v.v.
  - Xem báo cáo tổng hợp về chi tiêu và thu nhập hàng tháng.
  - Phân loại chi tiêu và thu nhập theo các danh mục khác nhau (Ví dụ: Nhà cửa, Ăn uống, Di chuyển, Tiết kiệm, v.v.)
  - Thống kê tỷ lệ chi tiêu so với thu nhập và các mục tiêu tài chính.

---

## Các yêu cầu chính:

### **Frontend**:
- Giao diện người dùng thân thiện, dễ sử dụng.
- Hỗ trợ giao diện xem báo cáo chi tiết và tóm tắt.
- Sử dụng **HTML**, **CSS** (với TailwindCSS hoặc Bootstrap), và **JavaScript** (với **React** hoặc **Vanilla JS**).
- Có thể tải lên và lưu trữ dữ liệu vào cơ sở dữ liệu MongoDB từ phía backend.
- Cung cấp các biểu đồ hoặc đồ thị đơn giản để hiển thị thống kê chi tiêu và thu nhập.

### **Backend**:
- Sử dụng **Golang** với **Gin** hoặc **Echo** framework để xây dựng các RESTful API.
- Sử dụng **MongoDB** làm cơ sở dữ liệu để lưu trữ thông tin về chi tiêu, thu nhập, các khoản chi phí, và người dùng.
- **JWT Authentication** để bảo mật và chỉ cho phép đăng nhập duy nhất một tài khoản cá nhân.

### **Quản lý người dùng**:
- Chức năng đăng ký và đăng nhập đơn giản (dành riêng cho cá nhân).
- Lưu trữ thông tin người dùng, các mục tiêu tài chính và các thống kê chi tiêu.
- **Công thức xác thực và bảo mật**: Mật khẩu sẽ được mã hóa và lưu trữ an toàn.

---

## Cấu trúc cơ bản của website:

1. **Trang Login**:
   - Nhập tên người dùng và mật khẩu.
   - Xác thực thông qua API backend và trả về JWT token.
   
2. **Trang Dashboard**:
   - Tổng hợp chi tiêu và thu nhập của tháng.
   - Biểu đồ và bảng thống kê chi tiết.
   
3. **Trang Nhập Chi Tiêu**:
   - Nhập các khoản chi tiêu (loại chi phí, số tiền, ngày tháng).
   - Lưu trữ chi tiêu vào cơ sở dữ liệu MongoDB.
   
4. **Trang Nhập Thu Nhập**:
   - Nhập các nguồn thu nhập (tiền lương, lợi nhuận từ đầu tư, v.v.).
   - Lưu trữ thu nhập vào cơ sở dữ liệu MongoDB.
   
5. **Trang Báo Cáo**:
   - Thống kê chi tiêu và thu nhập theo các tiêu chí thời gian (theo tháng, quý, năm).
   - Tính toán tỷ lệ chi tiêu/thu nhập và các mục tiêu tài chính.

---

## Các API cần thiết:

- **POST /login**: Đăng nhập với username và password, trả về **JWT token**.
- **POST /register**: Đăng ký tài khoản mới.
- **GET /expenses**: Lấy danh sách các khoản chi tiêu.
- **POST /expenses**: Thêm mới chi tiêu.
- **PUT /expenses/{id}**: Sửa thông tin chi tiêu.
- **DELETE /expenses/{id}**: Xóa chi tiêu.
- **GET /income**: Lấy danh sách thu nhập.
- **POST /income**: Thêm thu nhập mới.
- **PUT /income/{id}**: Sửa thông tin thu nhập.
- **DELETE /income/{id}**: Xóa thu nhập.

---

## Cấu trúc dữ liệu trong MongoDB:

- **Collection: users**
  - `username`: String
  - `password`: String (được mã hóa)
  - `email`: String
  - `created_at`: Date
  - `updated_at`: Date

- **Collection: expenses**
  - `user_id`: ObjectId (tham chiếu đến người dùng)
  - `amount`: Float
  - `category`: String (ví dụ: "Nhà cửa", "Ăn uống", v.v.)
  - `description`: String (mô tả chi tiết)
  - `date`: Date
  - `created_at`: Date

- **Collection: income**
  - `user_id`: ObjectId (tham chiếu đến người dùng)
  - `amount`: Float
  - `source`: String (ví dụ: "Lương", "Lợi nhuận đầu tư")
  - `date`: Date
  - `created_at`: Date

---

## Quy tắc AI khi phát triển web:

1. **Bảo mật và bảo vệ dữ liệu**:
   - Sử dụng **JWT** để xác thực và bảo mật các API.
   - Mã hóa mật khẩu người dùng trước khi lưu trữ vào MongoDB (sử dụng **bcrypt**).
   - Không lưu trữ mật khẩu dưới dạng văn bản thuần túy.

2. **Quản lý chi tiêu và thu nhập thông minh**:
   - Hệ thống phải có khả năng tính toán tỷ lệ chi tiêu so với thu nhập.
   - Các thông báo và cảnh báo khi chi tiêu vượt quá thu nhập.
   - Cung cấp các báo cáo chi tiết và tóm tắt dễ hiểu cho người dùng.

3. **Tính dễ sử dụng**:
   - Giao diện người dùng cần phải dễ sử dụng và tối giản.
   - Tạo các báo cáo đơn giản và dễ đọc với biểu đồ trực quan, giúp người dùng dễ dàng theo dõi và hiểu rõ tình hình tài chính của mình.

4. **Khả năng mở rộng**:
   - Đảm bảo mã nguồn dễ duy trì và mở rộng trong tương lai.
   - Tối ưu hóa API cho hiệu suất cao và dễ dàng mở rộng với các tính năng mới (ví dụ: nhập liệu qua Excel, thông báo qua email, v.v.).

5. **Đảm bảo tuân thủ các quy định về bảo mật**:
   - Mã hóa dữ liệu nhạy cảm (như thông tin tài chính) khi truyền tải qua mạng (sử dụng HTTPS).
   - Sử dụng các biện pháp bảo mật tiêu chuẩn như kiểm tra CSRF, bảo vệ chống SQL Injection, v.v.

---