import React, { useState } from 'react';
import { Bell, Search, Mail, User, Clock, ChevronDown, Settings } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

export function Header() {
  const [showNotifications, setShowNotifications] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  const currentDate = new Date();
  const dateStr = currentDate.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' });
  const timeStr = currentDate.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', timeZoneName: 'short' });

  return (
    <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-8 shadow-sm sticky top-0 z-50">
      <div className="flex items-center flex-1 max-w-2xl">
        <div className="relative w-full">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-5 h-5" />
          <input 
            type="text" 
            placeholder="Search flights, routes, aircraft, or staff..." 
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-slate-200 bg-slate-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white focus:border-blue-500 transition-all"
          />
          {searchQuery && (
            <button 
              onClick={() => setSearchQuery('')}
              className="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400 hover:text-slate-600"
            >
              ×
            </button>
          )}
        </div>
      </div>
      
      <div className="flex items-center space-x-4 ml-6">
        <div className="flex items-center space-x-2 px-3 py-1.5 bg-slate-50 rounded-lg border border-slate-200">
          <Clock className="w-4 h-4 text-slate-500" />
          <div className="flex flex-col">
            <span className="text-xs font-semibold text-slate-700 leading-tight">{dateStr}</span>
            <span className="text-xs text-slate-500 leading-tight">{timeStr}</span>
          </div>
        </div>
        
        <div className="relative">
          <button 
            onClick={() => setShowNotifications(!showNotifications)}
            className="relative p-2 rounded-lg hover:bg-slate-100 transition-colors"
          >
            <Bell className="w-5 h-5 text-slate-600" />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white animate-pulse"></span>
          </button>
          <AnimatePresence>
            {showNotifications && (
              <motion.div
                key="notifications"
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg border border-slate-200 p-4"
              >
                <div className="flex justify-between items-center mb-3">
                  <h3 className="font-semibold text-slate-900">Notifications</h3>
                  <button className="text-xs text-blue-600 hover:text-blue-800">Mark all read</button>
                </div>
                <div className="space-y-2 text-sm">
                  <div className="p-3 bg-blue-50 rounded-lg border border-blue-100">
                    <p className="font-medium text-slate-900">New route approved</p>
                    <p className="text-xs text-slate-500 mt-1">JFK → LHR route is now active</p>
                  </div>
                  <div className="p-3 bg-amber-50 rounded-lg border border-amber-100">
                    <p className="font-medium text-slate-900">Maintenance required</p>
                    <p className="text-xs text-slate-500 mt-1">Boeing 737 MAX 8 needs service</p>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
        
        <button className="relative p-2 rounded-lg hover:bg-slate-100 transition-colors">
          <Mail className="w-5 h-5 text-slate-600" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-blue-500 rounded-full border-2 border-white"></span>
        </button>
        
        <div className="relative pl-4 border-l border-slate-200">
          <button 
            onClick={() => setShowProfile(!showProfile)}
            className="flex items-center space-x-3 hover:bg-slate-50 rounded-lg p-1.5 transition-colors"
          >
            <div className="text-right hidden sm:block">
              <p className="text-sm font-semibold text-slate-800">Alex Sterling</p>
              <p className="text-xs text-slate-500">CEO</p>
            </div>
            <div className="w-10 h-10 rounded-full overflow-hidden border-2 border-slate-200 shadow-sm bg-slate-200 ring-2 ring-slate-100">
              <img 
                src="https://images.unsplash.com/photo-1681157889132-5446784b2e26?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhaXJsaW5lJTIwcGlsb3QlMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3Njg5NDU1MDB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" 
                alt="CEO"
                className="w-full h-full object-cover"
              />
            </div>
            <ChevronDown className="w-4 h-4 text-slate-500 hidden sm:block" />
          </button>
          <AnimatePresence>
            {showProfile && (
              <motion.div
                key="profile"
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="absolute right-0 mt-2 w-56 bg-white rounded-xl shadow-lg border border-slate-200 p-2"
              >
                <div className="p-3 border-b border-slate-100">
                  <p className="font-semibold text-slate-900">Alex Sterling</p>
                  <p className="text-xs text-slate-500">alex@skyhigh.com</p>
                </div>
                <button className="w-full flex items-center space-x-2 px-3 py-2 text-sm text-slate-700 hover:bg-slate-50 rounded-lg transition-colors">
                  <Settings className="w-4 h-4" />
                  <span>Settings</span>
                </button>
                <button className="w-full flex items-center space-x-2 px-3 py-2 text-sm text-slate-700 hover:bg-slate-50 rounded-lg transition-colors">
                  <User className="w-4 h-4" />
                  <span>Profile</span>
                </button>
                <div className="border-t border-slate-100 mt-2 pt-2">
                  <button className="w-full flex items-center space-x-2 px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition-colors">
                    <span>Sign Out</span>
                  </button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </header>
  );
}
