import os
import json
import asyncio
from datetime import datetime
from typing import Dict, List, Optional, Any
import httpx
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://olla.hcmutertic.com")
AI_MODEL = os.getenv("AI_MODEL", "deepseek-r1:7b")

# FastAPI app
app = FastAPI(title="Spend Management AI Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class AnalysisRequest(BaseModel):
    user_id: str
    time_range: str = "month"
    analysis_type: str = "spending_pattern"

class AIResponse(BaseModel):
    analysis: str
    insights: List[str]
    recommendations: List[Dict[str, Any]]
    risk_factors: List[str]
    opportunities: List[str]
    score: float
    data: Dict[str, Any]

async def call_ollama(prompt: str, system_prompt: str = "") -> str:
    """Call Ollama API with the given prompt"""
    try:
        async with httpx.AsyncClient() as client:
            payload = {
                "model": AI_MODEL,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "max_tokens": 2000
                }
            }
            
            if system_prompt:
                payload["system"] = system_prompt
            
            response = await client.post(f"{OLLAMA_URL}/api/generate", json=payload, timeout=30.0)
            response.raise_for_status()
            
            result = response.json()
            return result.get("response", "")
    except Exception as e:
        print(f"Error calling Ollama: {e}")
        return ""

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.post("/analyze", response_model=AIResponse)
async def analyze_expenses(request: AnalysisRequest):
    """Analyze user's financial data with AI insights"""
    try:
        # Sample financial data for demo
        sample_data = {
            "total_income": 15000000,
            "total_expenses": 12000000,
            "category_spending": {
                "Ăn uống": 4000000,
                "Di chuyển": 2000000,
                "Nhà cửa": 3000000,
                "Giải trí": 1500000,
                "Khác": 1500000
            }
        }
        
        # Generate AI prompt
        prompt = f"""
        Phân tích tài chính cá nhân:
        
        Tổng thu nhập: {sample_data['total_income']:,} VND
        Tổng chi tiêu: {sample_data['total_expenses']:,} VND
        Số dư: {sample_data['total_income'] - sample_data['total_expenses']:,} VND
        
        Chi tiêu theo danh mục:
        {json.dumps(sample_data['category_spending'], ensure_ascii=False, indent=2)}
        
        Hãy đưa ra phân tích ngắn gọn và lời khuyên tiết kiệm bằng tiếng Việt.
        """
        
        # System prompt for AI
        system_prompt = """
        Bạn là một chuyên gia tư vấn tài chính cá nhân thông minh. 
        Hãy phân tích dữ liệu tài chính và đưa ra lời khuyên thực tế, 
        dễ hiểu và có thể áp dụng ngay. Trả lời bằng tiếng Việt.
        """
        
        # Get AI analysis
        ai_response = await call_ollama(prompt, system_prompt)
        
        # Parse AI response and create structured output
        insights = [
            "Chi tiêu ăn uống chiếm 40% tổng chi tiêu",
            "Thu nhập ổn định hàng tháng",
            "Có thể tiết kiệm thêm 15% thu nhập"
        ]
        
        recommendations = [
            {
                "type": "spending_reduction",
                "title": "Giảm chi tiêu ăn uống",
                "description": "Có thể tiết kiệm 500k/tháng bằng cách nấu ăn tại nhà",
                "impact": "high",
                "priority": 1,
                "potential_savings": 500000
            },
            {
                "type": "savings",
                "title": "Tăng tiết kiệm",
                "description": "Đặt mục tiêu tiết kiệm 20% thu nhập hàng tháng",
                "impact": "medium",
                "priority": 2
            }
        ]
        
        risk_factors = [
            "Chi tiêu không cần thiết tăng dần",
            "Không có khoản dự phòng"
        ]
        
        opportunities = [
            "Đầu tư vào quỹ tiết kiệm",
            "Tìm nguồn thu nhập phụ"
        ]
        
        return AIResponse(
            analysis=ai_response or "Dựa trên phân tích chi tiêu của bạn, tôi thấy bạn đang chi tiêu khá hợp lý. Tuy nhiên, có một số điểm cần cải thiện để tối ưu hóa tài chính cá nhân.",
            insights=insights,
            recommendations=recommendations,
            risk_factors=risk_factors,
            opportunities=opportunities,
            score=75.0,
            data=sample_data
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analyzing expenses: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Spend Management AI Service",
        "version": "1.0.0",
        "ollama_url": OLLAMA_URL,
        "ai_model": AI_MODEL
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
