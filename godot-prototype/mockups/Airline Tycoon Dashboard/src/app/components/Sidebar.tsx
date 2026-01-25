import React from 'react';
import { motion } from 'motion/react';
import { LayoutDashboard, Plane, Map, PieChart, Users, Settings, LogOut, ChevronRight } from 'lucide-react';
import { cn } from '@/lib/utils';

interface SidebarProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export function Sidebar({ activeTab, setActiveTab }: SidebarProps) {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard, badge: null },
    { id: 'fleet', label: 'Fleet Management', icon: Plane, badge: '5' },
    { id: 'routes', label: 'Route Map', icon: Map, badge: null },
    { id: 'finances', label: 'Finances', icon: PieChart, badge: null },
    { id: 'staff', label: 'Staff', icon: Users, badge: '145' },
  ];

  return (
    <div className="flex flex-col h-full w-64 bg-gradient-to-b from-slate-900 to-slate-800 text-white border-r border-slate-800 shadow-2xl">
      {/* Logo Section */}
      <div className="p-6 flex items-center space-x-3 border-b border-slate-800/50">
        <motion.div 
          className="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center transform rotate-45 shadow-lg shadow-blue-500/30"
          whileHover={{ scale: 1.1, rotate: 45 }}
          transition={{ type: "spring", stiffness: 300 }}
        >
          <Plane className="w-7 h-7 text-white transform -rotate-45" />
        </motion.div>
        <div>
          <h1 className="font-bold text-xl tracking-wide bg-gradient-to-r from-white to-blue-200 bg-clip-text text-transparent">
            SKYHIGH
          </h1>
          <p className="text-xs text-slate-400 uppercase tracking-wider">Tycoon</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 py-6 px-3 space-y-1 overflow-y-auto">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          return (
            <motion.button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={cn(
                "w-full flex items-center justify-between px-4 py-3 rounded-xl transition-all duration-200 group relative overflow-hidden",
                isActive 
                  ? "bg-gradient-to-r from-blue-600 to-blue-500 text-white shadow-lg shadow-blue-500/30" 
                  : "text-slate-400 hover:bg-slate-800/50 hover:text-white"
              )}
              whileHover={{ x: 4 }}
              whileTap={{ scale: 0.98 }}
            >
              <div className="flex items-center space-x-3">
                {isActive && (
                  <motion.div
                    layoutId="activeTabIndicator"
                    className="absolute left-0 w-1 h-8 bg-white rounded-r-full"
                    initial={{ opacity: 0, scaleY: 0 }}
                    animate={{ opacity: 1, scaleY: 1 }}
                    exit={{ opacity: 0, scaleY: 0 }}
                    transition={{ duration: 0.2 }}
                  />
                )}
                <Icon className={cn(
                  "w-5 h-5 transition-transform group-hover:scale-110",
                  isActive ? "text-white" : "text-slate-500 group-hover:text-white"
                )} />
                <span className="font-medium text-sm">{item.label}</span>
              </div>
              {item.badge && (
                <span className={cn(
                  "px-2 py-0.5 rounded-full text-xs font-bold",
                  isActive 
                    ? "bg-white/20 text-white" 
                    : "bg-slate-700 text-slate-300 group-hover:bg-slate-600"
                )}>
                  {item.badge}
                </span>
              )}
              {isActive && (
                <ChevronRight className="w-4 h-4 text-white" />
              )}
            </motion.button>
          );
        })}
      </nav>

      {/* Footer Actions */}
      <div className="p-4 border-t border-slate-800/50 space-y-1">
        <button className="w-full flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:bg-slate-800/50 hover:text-white transition-colors group">
          <Settings className="w-5 h-5 group-hover:rotate-90 transition-transform duration-300" />
          <span className="font-medium text-sm">Settings</span>
        </button>
        <button className="w-full flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-colors group">
          <LogOut className="w-5 h-5" />
          <span className="font-medium text-sm">Sign Out</span>
        </button>
      </div>
    </div>
  );
}
