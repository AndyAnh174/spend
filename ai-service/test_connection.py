#!/usr/bin/env python3
"""
Test script to verify connection to remote Ollama server
"""

import asyncio
import httpx
import json
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://olla.hcmutertic.com")
AI_MODEL = os.getenv("AI_MODEL", "deepseek-r1:8b")

async def test_basic_connection():
    """Test basic connection to Ollama server"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{OLLAMA_URL}/api/tags")
            if response.status_code == 200:
                print("✅ Basic connection successful")
                models = response.json()
                print(f"Available models: {[model['name'] for model in models.get('models', [])]}")
                return True
            else:
                print(f"❌ Connection failed with status: {response.status_code}")
                return False
    except Exception as e:
        print(f"❌ Connection error: {e}")
        return False

async def test_model_availability():
    """Test if the specified model is available"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{OLLAMA_URL}/api/tags")
            if response.status_code == 200:
                models = response.json()
                available_models = [model['name'] for model in models.get('models', [])]
                
                if AI_MODEL in available_models:
                    print(f"✅ Model '{AI_MODEL}' is available")
                    return True
                else:
                    print(f"❌ Model '{AI_MODEL}' not found")
                    print(f"Available models: {available_models}")
                    return False
    except Exception as e:
        print(f"❌ Model check error: {e}")
        return False

async def test_ai_generation():
    """Test AI model generation"""
    try:
        async with httpx.AsyncClient() as client:
            payload = {
                "model": AI_MODEL,
                "prompt": "Xin chào, đây là tin nhắn test. Hãy trả lời ngắn gọn bằng tiếng Việt.",
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "max_tokens": 100
                }
            }
            
            response = await client.post(
                f"{OLLAMA_URL}/api/generate",
                json=payload,
                timeout=30.0
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ AI generation successful")
                print(f"Response: {result.get('response', 'No response')[:100]}...")
                return True
            else:
                print(f"❌ AI generation failed with status: {response.status_code}")
                print(f"Response: {response.text}")
                return False
    except Exception as e:
        print(f"❌ AI generation error: {e}")
        return False

async def test_financial_analysis():
    """Test financial analysis with sample data"""
    try:
        async with httpx.AsyncClient() as client:
            # Sample financial data
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
            
            prompt = f"""
            Phân tích tài chính cá nhân:
            
            Tổng thu nhập: {sample_data['total_income']:,} VND
            Tổng chi tiêu: {sample_data['total_expenses']:,} VND
            Số dư: {sample_data['total_income'] - sample_data['total_expenses']:,} VND
            
            Chi tiêu theo danh mục:
            {json.dumps(sample_data['category_spending'], ensure_ascii=False, indent=2)}
            
            Hãy đưa ra phân tích ngắn gọn và lời khuyên tiết kiệm.
            """
            
            payload = {
                "model": AI_MODEL,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "max_tokens": 300
                }
            }
            
            response = await client.post(
                f"{OLLAMA_URL}/api/generate",
                json=payload,
                timeout=60.0
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ Financial analysis test successful")
                print(f"Analysis: {result.get('response', 'No response')[:200]}...")
                return True
            else:
                print(f"❌ Financial analysis failed with status: {response.status_code}")
                return False
    except Exception as e:
        print(f"❌ Financial analysis error: {e}")
        return False

async def main():
    """Run all tests"""
    print("=" * 50)
    print("Testing Remote Ollama Server Connection")
    print("=" * 50)
    print(f"Server URL: {OLLAMA_URL}")
    print(f"AI Model: {AI_MODEL}")
    print()
    
    tests = [
        ("Basic Connection", test_basic_connection),
        ("Model Availability", test_model_availability),
        ("AI Generation", test_ai_generation),
        ("Financial Analysis", test_financial_analysis)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        print(f"Running {test_name}...")
        result = await test_func()
        results.append((test_name, result))
        print()
    
    # Summary
    print("=" * 50)
    print("Test Summary")
    print("=" * 50)
    
    passed = 0
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name}: {status}")
        if result:
            passed += 1
    
    print()
    print(f"Tests passed: {passed}/{len(results)}")
    
    if passed == len(results):
        print("🎉 All tests passed! Your setup is ready.")
        print("You can now run: start.bat")
    else:
        print("⚠️  Some tests failed. Please check your configuration.")
    
    print("=" * 50)

if __name__ == "__main__":
    asyncio.run(main())
