'use client';

import { useState, type JSX } from 'react';
import { useNavigate } from 'react-router-dom';
import { getAuth, signOut } from 'firebase/auth';
import { firebaseApp } from '../firebase/firebase';
import { useAuth } from '../context/AuthContext';
import './css/dashboard.css';
import {
  Users,
  MessageSquare,
  FileText,
  Bell,
  TrendingUp,
  Activity,
  Brain,
  LogOut,
  Database,
  Cpu,
  HardDrive,
  Wifi
} from 'lucide-react';
import UserManagement from './UserManagement';

type TabKey = 'overview' | 'users' | 'chatbot' | 'notes' | 'reminders' | 'analytics';

interface Stat {
  title: string;
  value: string;
  subtitle: string;
  icon: JSX.Element;
}

interface Alert {
  color: string;
  text: string;
  time: string;
}

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState<TabKey>('overview');
  const navigate = useNavigate();
  const auth = getAuth(firebaseApp);
  const { setUser, setIsAdmin } = useAuth();

  const handleLogout = async () => {
    try {
      await signOut(auth);
      setUser(null);
      setIsAdmin(false);
      navigate('/login');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  const overviewStats: Stat[] = [
    { title: 'Total Users', value: '1,247', subtitle: '+12% from last month', icon: <Users size={18} /> },
    { title: 'Active Users', value: '892', subtitle: '71.5% engagement rate', icon: <Activity size={18} /> },
    { title: 'Journal Entries', value: '5,634', subtitle: '+8% from last week', icon: <FileText size={18} /> },
    { title: 'Chatbot Interactions', value: '12,890', subtitle: '+23% from last month', icon: <MessageSquare size={18} /> },
    { title: 'Active Reminders', value: '3,456', subtitle: '89% completion rate', icon: <Bell size={18} /> },
    { title: 'Avg Sentiment Score', value: '0.72', subtitle: '+0.05 from last week', icon: <TrendingUp size={18} /> }
  ];

  const alerts: Alert[] = [
    { color: 'green', text: 'All services operational', time: '2 min ago' },
    { color: 'blue', text: 'Database backup completed', time: '1 hour ago' },
    { color: 'yellow', text: 'High API usage detected', time: '3 hours ago' }
  ];

  return (
    <div className="dashboard-page">
      {/* Header */}
      <header className="dashboard-header">
        <div className="header-left">
          <Brain className="logo" />
          <span className="title">Mental Health Admin</span>
        </div>
        <div className="header-right">
          <div className="system-status">
            <Activity size={14} className="status-icon" /> System Healthy
          </div>
          <button className="logout-btn" onClick={handleLogout}>
            <LogOut size={14} /> Logout
          </button>
        </div>
      </header>

      {/* Tabs */}
      <div className="tabs-container flex gap-2 mb-4">
        <button
          className={`tab-btn ${activeTab === 'overview' ? 'active' : ''}`}
          onClick={() => setActiveTab('overview')}
        >
          Overview
        </button>
        <button
          className={`tab-btn ${activeTab === 'users' ? 'active' : ''}`}
          onClick={() => setActiveTab('users')}
        >
          Users
        </button>
        <button
          className={`tab-btn ${activeTab === 'chatbot' ? 'active' : ''}`}
          onClick={() => setActiveTab('chatbot')}
        >
          Chatbot
        </button>
        <button
          className={`tab-btn ${activeTab === 'notes' ? 'active' : ''}`}
          onClick={() => setActiveTab('notes')}
        >
          Notes
        </button>
        <button
          className={`tab-btn ${activeTab === 'reminders' ? 'active' : ''}`}
          onClick={() => setActiveTab('reminders')}
        >
          Reminders
        </button>
        <button
          className={`tab-btn ${activeTab === 'analytics' ? 'active' : ''}`}
          onClick={() => setActiveTab('analytics')}
        >
          Analytics
        </button>
      </div>

      {/* Content */}
      {activeTab === 'overview' && (
        <div className="content">
          {/* Stats */}
          <div className="stats-grid">
            {overviewStats.map((stat, i) => (
              <div key={i} className="stat-card">
                <div className="stat-header">
                  <span>{stat.title}</span>
                  {stat.icon}
                </div>
                <div className="stat-value">{stat.value}</div>
                <div className="stat-sub">{stat.subtitle}</div>
              </div>
            ))}
          </div>

          {/* Bottom section */}
          <div className="bottom-grid">
            {/* Alerts */}
            <div className="alert-card">
              <h3>Recent System Alerts</h3>
              <p className="sub">Latest system notifications and alerts</p>
              <div className="alert-list">
                {alerts.map((a, idx) => (
                  <div key={idx} className={`alert-item bg-${a.color}-50`}>
                    <span className={`dot bg-${a.color}-500`}></span>
                    <span className="alert-text">{a.text}</span>
                    <span className="alert-time">{a.time}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* System Health */}
            <div className="alert-card">
              <h3>System Health</h3>
              <p className="sub">Real-time system performance metrics</p>
              <div className="health-item">
                <Database size={16} /> API Status <span className="badge green">operational</span>
              </div>
              <div className="health-item">
                <Database size={16} /> Database <span className="badge green">operational</span>
              </div>
              <div className="progress-item">
                <Cpu size={16} /> CPU Usage
                <div className="progress">
                  <div style={{ width: '45%' }}></div>
                </div>
              </div>
              <div className="progress-item">
                <HardDrive size={16} /> Memory Usage
                <div className="progress">
                  <div style={{ width: '62%' }}></div>
                </div>
              </div>
              <div className="progress-item">
                <HardDrive size={16} /> Disk Usage
                <div className="progress">
                  <div style={{ width: '38%' }}></div>
                </div>
              </div>
              <div className="health-item">
                <Wifi size={16} /> Network Latency <span className="latency">23ms</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'users' && <UserManagement />}
      {activeTab === 'chatbot' && <div>Chatbot Page</div>}
      {activeTab === 'notes' && <div>Notes Page</div>}
      {activeTab === 'reminders' && <div>Reminders Page</div>}
      {activeTab === 'analytics' && <div>Analytics Page</div>}
    </div>
  );
}
