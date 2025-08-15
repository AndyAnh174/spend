import React, { useState, useEffect } from 'react';
import { Chart as ChartJS, ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement } from 'chart.js';
import { Doughnut, Bar } from 'react-chartjs-2';
import axios from 'axios';

ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement);

interface AIAnalysisData {
  analysis: string;
  insights: string[];
  recommendations: Array<{
    type: string;
    title: string;
    description: string;
    impact: string;
    priority: number;
    potential_savings?: number;
  }>;
  risk_factors: string[];
  opportunities: string[];
  score: number;
  data: any;
}

const AIAnalysis: React.FC = () => {
  const [analysisData, setAnalysisData] = useState<AIAnalysisData | null>(null);
  const [loading, setLoading] = useState(false);
  const [timeRange, setTimeRange] = useState('month');
  const [analysisType, setAnalysisType] = useState('spending_pattern');

  const fetchAIAnalysis = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('token');
      const userId = localStorage.getItem('userId');
      
      const response = await axios.post(
        `${process.env.REACT_APP_AI_SERVICE_URL || 'http://localhost:8000'}/analyze`,
        {
          user_id: userId,
          time_range: timeRange,
          analysis_type: analysisType
        },
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );
      
      setAnalysisData(response.data);
    } catch (error) {
      console.error('Error fetching AI analysis:', error);
      // Fallback to mock data for demo
      setAnalysisData({
        analysis: "Dựa trên phân tích chi tiêu của bạn, tôi thấy bạn đang chi tiêu khá hợp lý. Tuy nhiên, có một số điểm cần cải thiện để tối ưu hóa tài chính cá nhân.",
        insights: [
          "Chi tiêu ăn uống chiếm 40% tổng chi tiêu",
          "Thu nhập ổn định hàng tháng",
          "Có thể tiết kiệm thêm 15% thu nhập"
        ],
        recommendations: [
          {
            type: "spending_reduction",
            title: "Giảm chi tiêu ăn uống",
            description: "Có thể tiết kiệm 500k/tháng bằng cách nấu ăn tại nhà",
            impact: "high",
            priority: 1,
            potential_savings: 500000
          },
          {
            type: "savings",
            title: "Tăng tiết kiệm",
            description: "Đặt mục tiêu tiết kiệm 20% thu nhập hàng tháng",
            impact: "medium",
            priority: 2
          }
        ],
        risk_factors: [
          "Chi tiêu không cần thiết tăng dần",
          "Không có khoản dự phòng"
        ],
        opportunities: [
          "Đầu tư vào quỹ tiết kiệm",
          "Tìm nguồn thu nhập phụ"
        ],
        score: 75,
        data: {
          total_spending: 8000000,
          category_breakdown: {
            "Ăn uống": 3200000,
            "Di chuyển": 1200000,
            "Nhà cửa": 2000000,
            "Giải trí": 800000,
            "Khác": 800000
          }
        }
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAIAnalysis();
  }, [timeRange, analysisType]);

  const getImpactColor = (impact: string) => {
    switch (impact) {
      case 'high': return 'text-red-600 bg-red-100';
      case 'medium': return 'text-yellow-600 bg-yellow-100';
      case 'low': return 'text-green-600 bg-green-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600';
    if (score >= 60) return 'text-yellow-600';
    return 'text-red-600';
  };

  const chartData = analysisData?.data?.category_breakdown ? {
    labels: Object.keys(analysisData.data.category_breakdown),
    datasets: [
      {
        data: Object.values(analysisData.data.category_breakdown),
        backgroundColor: [
          '#FF6384',
          '#36A2EB',
          '#FFCE56',
          '#4BC0C0',
          '#9966FF',
          '#FF9F40'
        ],
        borderWidth: 2,
      },
    ],
  } : null;

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">🤖 Phân Tích AI</h1>
        <p className="text-gray-600">Phân tích thông minh tình hình tài chính của bạn</p>
      </div>

      {/* Controls */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <div className="flex flex-wrap gap-4 items-center">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Thời gian phân tích
            </label>
            <select
              value={timeRange}
              onChange={(e) => setTimeRange(e.target.value)}
              className="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="week">Tuần này</option>
              <option value="month">Tháng này</option>
              <option value="quarter">Quý này</option>
              <option value="year">Năm nay</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Loại phân tích
            </label>
            <select
              value={analysisType}
              onChange={(e) => setAnalysisType(e.target.value)}
              className="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="spending_pattern">Mẫu chi tiêu</option>
              <option value="savings_advice">Lời khuyên tiết kiệm</option>
              <option value="budget_optimization">Tối ưu ngân sách</option>
            </select>
          </div>
          
          <button
            onClick={fetchAIAnalysis}
            disabled={loading}
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? 'Đang phân tích...' : 'Phân tích lại'}
          </button>
        </div>
      </div>

      {loading && (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">AI đang phân tích dữ liệu của bạn...</p>
        </div>
      )}

      {analysisData && !loading && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Financial Health Score */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">📊 Điểm Sức Khỏe Tài Chính</h2>
            <div className="text-center">
              <div className={`text-6xl font-bold ${getScoreColor(analysisData.score)}`}>
                {analysisData.score}
              </div>
              <div className="text-gray-600 mt-2">/ 100 điểm</div>
              <div className="mt-4">
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div 
                    className="bg-blue-600 h-3 rounded-full transition-all duration-500"
                    style={{ width: `${analysisData.score}%` }}
                  ></div>
                </div>
              </div>
            </div>
          </div>

          {/* Category Breakdown Chart */}
          {chartData && (
            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-semibold mb-4">📈 Phân Bổ Chi Tiêu</h2>
              <div className="h-64">
                <Doughnut 
                  data={chartData}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: {
                        position: 'bottom'
                      }
                    }
                  }}
                />
              </div>
            </div>
          )}
        </div>
      )}

      {analysisData && !loading && (
        <div className="mt-6 space-y-6">
          {/* AI Analysis */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">🧠 Phân Tích AI</h2>
            <div className="prose max-w-none">
              <p className="text-gray-700 leading-relaxed">{analysisData.analysis}</p>
            </div>
          </div>

          {/* Insights */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">💡 Nhận Định</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {analysisData.insights.map((insight, index) => (
                <div key={index} className="flex items-start space-x-3">
                  <div className="flex-shrink-0 w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                  <p className="text-gray-700">{insight}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Recommendations */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">🎯 Khuyến Nghị</h2>
            <div className="space-y-4">
              {analysisData.recommendations.map((rec, index) => (
                <div key={index} className="border-l-4 border-blue-500 pl-4 py-2">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold text-gray-900">{rec.title}</h3>
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${getImpactColor(rec.impact)}`}>
                      {rec.impact === 'high' ? 'Cao' : rec.impact === 'medium' ? 'Trung bình' : 'Thấp'}
                    </span>
                  </div>
                  <p className="text-gray-600 mb-2">{rec.description}</p>
                  {rec.potential_savings && (
                    <p className="text-green-600 font-medium">
                      Tiết kiệm tiềm năng: {rec.potential_savings.toLocaleString('vi-VN')} VND
                    </p>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Risk Factors & Opportunities */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-semibold mb-4 text-red-600">⚠️ Rủi Ro</h2>
              <ul className="space-y-2">
                {analysisData.risk_factors.map((risk, index) => (
                  <li key={index} className="flex items-start space-x-2">
                    <span className="text-red-500 mt-1">•</span>
                    <span className="text-gray-700">{risk}</span>
                  </li>
                ))}
              </ul>
            </div>

            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-semibold mb-4 text-green-600">🚀 Cơ Hội</h2>
              <ul className="space-y-2">
                {analysisData.opportunities.map((opportunity, index) => (
                  <li key={index} className="flex items-start space-x-2">
                    <span className="text-green-500 mt-1">•</span>
                    <span className="text-gray-700">{opportunity}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AIAnalysis;
