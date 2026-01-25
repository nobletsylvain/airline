import React, { useState } from 'react';
import { motion } from 'motion/react';
import { MapPin, TrendingUp, DollarSign, Clock, Plus, Search, Filter, Globe, TrendingDown, Users } from 'lucide-react';
import { cn } from '@/lib/utils';

const routes = [
  { id: 1, origin: 'New York (JFK)', dest: 'London (LHR)', dist: '3,451 mi', time: '7h 20m', profit: 45200, load: 92, passengers: 285, frequency: 'Daily', aircraft: 'Boeing 787-9' },
  { id: 2, origin: 'Los Angeles (LAX)', dest: 'Tokyo (HND)', dist: '5,488 mi', time: '11h 45m', profit: 68100, load: 88, passengers: 320, frequency: 'Daily', aircraft: 'Airbus A350-900' },
  { id: 3, origin: 'London (LHR)', dest: 'Dubai (DXB)', dist: '3,413 mi', time: '7h 10m', profit: 32500, load: 75, passengers: 195, frequency: '5x Weekly', aircraft: 'Boeing 737 MAX 8' },
  { id: 4, origin: 'Singapore (SIN)', dest: 'Sydney (SYD)', dist: '3,912 mi', time: '8h 15m', profit: 28900, load: 82, passengers: 245, frequency: 'Daily', aircraft: 'Airbus A320neo' },
  { id: 5, origin: 'Paris (CDG)', dest: 'New York (JFK)', dist: '3,635 mi', time: '8h 05m', profit: 38400, load: 85, passengers: 265, frequency: 'Daily', aircraft: 'Boeing 787-9' },
];

export function Routes() {
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState<'profit' | 'load' | 'passengers'>('profit');

  const filteredRoutes = routes.filter(route => {
    return route.origin.toLowerCase().includes(searchQuery.toLowerCase()) || 
           route.dest.toLowerCase().includes(searchQuery.toLowerCase());
  });

  const sortedRoutes = [...filteredRoutes].sort((a, b) => {
    if (sortBy === 'profit') return b.profit - a.profit;
    if (sortBy === 'load') return b.load - a.load;
    return b.passengers - a.passengers;
  });

  const totalProfit = routes.reduce((sum, r) => sum + r.profit, 0);
  const avgLoad = Math.round(routes.reduce((sum, r) => sum + r.load, 0) / routes.length);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Route Network</h1>
          <p className="text-slate-500 mt-1">Manage your flight routes and monitor performance</p>
        </div>
        <button className="flex items-center space-x-2 bg-blue-600 text-white px-5 py-2.5 rounded-lg font-medium hover:bg-blue-700 transition-all shadow-lg shadow-blue-500/30 hover:shadow-xl">
          <Plus className="w-5 h-5" />
          <span>Launch New Route</span>
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 p-6 rounded-xl text-white">
          <div className="flex items-center justify-between mb-2">
            <span className="text-blue-100 text-sm font-medium">Total Routes</span>
            <Globe className="w-5 h-5 text-blue-200" />
          </div>
          <div className="text-3xl font-bold">{routes.length}</div>
          <div className="text-blue-100 text-xs mt-1">Active connections</div>
        </div>
        <div className="bg-gradient-to-br from-emerald-500 to-emerald-600 p-6 rounded-xl text-white">
          <div className="flex items-center justify-between mb-2">
            <span className="text-emerald-100 text-sm font-medium">Daily Revenue</span>
            <DollarSign className="w-5 h-5 text-emerald-200" />
          </div>
          <div className="text-3xl font-bold">${(totalProfit / 1000).toFixed(0)}k</div>
          <div className="text-emerald-100 text-xs mt-1">Across all routes</div>
        </div>
        <div className="bg-gradient-to-br from-indigo-500 to-indigo-600 p-6 rounded-xl text-white">
          <div className="flex items-center justify-between mb-2">
            <span className="text-indigo-100 text-sm font-medium">Avg. Load Factor</span>
            <TrendingUp className="w-5 h-5 text-indigo-200" />
          </div>
          <div className="text-3xl font-bold">{avgLoad}%</div>
          <div className="text-indigo-100 text-xs mt-1">Passenger capacity</div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-100">
        <div className="flex flex-col md:flex-row gap-4 items-center">
          <div className="relative flex-1 w-full">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-5 h-5" />
            <input 
              type="text" 
              placeholder="Search routes by origin or destination..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-slate-200 bg-slate-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
            />
          </div>
          <select 
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as any)}
            className="px-4 py-2.5 rounded-lg border border-slate-200 bg-slate-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="profit">Sort by Profit</option>
            <option value="load">Sort by Load Factor</option>
            <option value="passengers">Sort by Passengers</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Map View */}
        <motion.div 
          className="lg:col-span-2 bg-slate-900 rounded-2xl overflow-hidden shadow-lg relative min-h-[500px] group"
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
        >
          <img 
            src="https://images.unsplash.com/photo-1731700128691-16fcc9043d11?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b3JsZCUyMG1hcCUyMHZlY3RvciUyMGFic3RyYWN0JTIwYmx1ZXxlbnwxfHx8fDE3Njg5NDU1MDB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" 
            alt="World Map" 
            className="w-full h-full object-cover opacity-70 group-hover:opacity-80 transition-opacity"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-slate-900/90 via-slate-900/20 to-transparent"></div>
          
          <div className="absolute top-6 left-6 right-6">
            <div className="bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/20">
              <div className="flex items-center justify-between">
                <div>
                  <div className="flex items-center space-x-2 mb-1">
                    <div className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse"></div>
                    <span className="text-white font-semibold text-sm">Live Operations</span>
                  </div>
                  <p className="text-white/80 text-xs">{routes.length} Active Routes</p>
                </div>
                <div className="text-right">
                  <div className="text-white font-bold text-lg">{routes.length * 2}</div>
                  <p className="text-white/80 text-xs">Daily Flights</p>
                </div>
              </div>
            </div>
          </div>
          
          <div className="absolute bottom-6 left-6 right-6">
            <div className="bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/20">
              <div className="flex items-center justify-between mb-2">
                <span className="text-white/90 text-sm font-medium">Network Coverage</span>
                <span className="text-white font-bold">12 Countries</span>
              </div>
              <div className="h-2 bg-slate-700/50 rounded-full overflow-hidden">
                <motion.div 
                  className="h-full bg-gradient-to-r from-blue-500 to-emerald-500"
                  initial={{ width: 0 }}
                  animate={{ width: '78%' }}
                  transition={{ duration: 1, delay: 0.5 }}
                />
              </div>
            </div>
          </div>
        </motion.div>

        {/* Route List */}
        <div className="space-y-3">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-slate-800">Route Performance</h3>
            <span className="text-xs text-slate-500">{sortedRoutes.length} routes</span>
          </div>
          {sortedRoutes.map((route, i) => (
            <motion.div 
              key={route.id}
              className="bg-white p-4 rounded-xl shadow-sm border border-slate-100 hover:shadow-md hover:border-blue-200 transition-all cursor-pointer group"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.05 }}
              whileHover={{ x: 4 }}
            >
              <div className="flex justify-between items-start mb-3">
                <div className="flex items-center space-x-3 flex-1">
                   <div className="p-2 bg-blue-50 rounded-lg group-hover:bg-blue-100 transition-colors">
                     <MapPin className="w-4 h-4 text-blue-600" />
                   </div>
                   <div className="flex-1 min-w-0">
                     <div className="font-bold text-slate-800 text-sm truncate">
                       {route.origin.split('(')[1].replace(')','')} → {route.dest.split('(')[1].replace(')','')}
                     </div>
                     <div className="text-xs text-slate-500 mt-0.5">{route.dist} • {route.frequency}</div>
                   </div>
                </div>
                <div className={cn(
                  "px-2.5 py-1 rounded-full text-xs font-bold border",
                  route.load > 90 ? "bg-emerald-50 text-emerald-700 border-emerald-200" : 
                  route.load > 75 ? "bg-blue-50 text-blue-700 border-blue-200" :
                  "bg-amber-50 text-amber-700 border-amber-200"
                )}>
                  {route.load}%
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-3 pt-3 border-t border-slate-50">
                 <div className="flex items-center text-xs text-slate-600">
                   <Clock className="w-3 h-3 mr-1.5" />
                   <span>{route.time}</span>
                 </div>
                 <div className="flex items-center text-xs text-slate-600">
                   <Users className="w-3 h-3 mr-1.5" />
                   <span>{route.passengers} pax</span>
                 </div>
                 <div className="flex items-center text-xs font-semibold text-emerald-600 col-span-2">
                   <DollarSign className="w-3 h-3 mr-1" />
                   <span>${route.profit.toLocaleString()} / day</span>
                 </div>
              </div>
              <div className="mt-2 text-xs text-slate-400">{route.aircraft}</div>
            </motion.div>
          ))}
        </div>
      </div>
    </div>
  );
}
