import React, { useState } from 'react';
import { Sidebar } from './components/Sidebar';
import { Header } from './components/Header';
import { Overview } from './components/Overview';
import { Fleet } from './components/Fleet';
import { Routes } from './components/Routes';
import { Finances } from './components/Finances';
import { Staff } from './components/Staff';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');

  return (
    <div className="flex h-screen bg-slate-50 font-sans text-slate-900 overflow-hidden">
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />
      
      <div className="flex-1 flex flex-col h-full overflow-hidden">
        <Header />
        
        <main className="flex-1 overflow-y-auto p-8">
          <div className="max-w-7xl mx-auto">
            {activeTab === 'dashboard' && <Overview />}
            {activeTab === 'fleet' && <Fleet />}
            {activeTab === 'routes' && <Routes />}
            {activeTab === 'finances' && <Finances />}
            {activeTab === 'staff' && <Staff />}
          </div>
        </main>
      </div>
    </div>
  );
}
