import React from 'react';
import { motion } from 'motion/react';
import { MapPin, TrendingUp, DollarSign, Clock, Plus } from 'lucide-react';
import { cn } from '@/lib/utils';

const routes = [
  { id: 1, origin: 'New York (JFK)', dest: 'London (LHR)', dist: '3,451 mi', time: '7h 20m', profit: 45200, load: 92 },
  { id: 2, origin: 'Los Angeles (LAX)', dest: 'Tokyo (HND)', dist: '5,488 mi', time: '11h 45m', profit: 68100, load: 88 },
  { id: 3, origin: 'London (LHR)', dest: 'Dubai (DXB)', dist: '3,413 mi', time: '7h 10m', profit: 32500, load: 75 },
  { id: 4, origin: 'Singapore (SIN)', dest: 'Sydney (SYD)', dist: '3,912 mi', time: '8h 15m', profit: 28900, load: 82 },
  { id: 5, origin: 'Paris (CDG)', dest: 'New York (JFK)', dist: '3,635 mi', time: '8h 05m', profit: 38400, load: 85 },
];

export function Routes() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-slate-800">Route Network</h2>
        <button className="bg-blue-600 text-white px-5 py-2 rounded-lg font-medium hover:bg-blue-700 transition-colors shadow-lg shadow-blue-500/30 flex items-center">
          <Plus className="w-5 h-5 mr-2" />
          Launch New Route
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Map View */}
        <motion.div 
          className="lg:col-span-2 bg-slate-900 rounded-2xl overflow-hidden shadow-lg relative min-h-[400px]"
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
        >
          <img 
            src="https://images.unsplash.com/photo-1731700128691-16fcc9043d11?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b3JsZCUyMG1hcCUyMHZlY3RvciUyMGFic3RyYWN0JTIwYmx1ZXxlbnwxfHx8fDE3Njg5NDU1MDB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" 
            alt="World Map" 
            className="w-full h-full object-cover opacity-60"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-slate-900 via-transparent to-transparent"></div>
          
          <div className="absolute bottom-6 left-6 right-6">
            <div className="flex items-center space-x-2 mb-2">
              <div className="w-3 h-3 bg-emerald-500 rounded-full animate-pulse"></div>
              <span className="text-white font-medium text-sm">Live Operations: 5 Flights Active</span>
            </div>
            <div className="h-1 bg-slate-700 rounded-full overflow-hidden">
               <div className="w-1/3 h-full bg-emerald-500"></div>
            </div>
          </div>
        </motion.div>

        {/* Route List */}
        <div className="space-y-4">
          <h3 className="font-bold text-slate-700 mb-2">Top Performing Routes</h3>
          {routes.map((route, i) => (
            <motion.div 
              key={route.id}
              className="bg-white p-4 rounded-xl shadow-sm border border-slate-100 hover:shadow-md transition-all cursor-pointer"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.1 }}
            >
              <div className="flex justify-between items-start mb-3">
                <div className="flex items-center space-x-2">
                   <div className="p-2 bg-blue-50 rounded-lg">
                     <MapPin className="w-4 h-4 text-blue-600" />
                   </div>
                   <div>
                     <div className="font-bold text-slate-800 text-sm">{route.origin.split('(')[1].replace(')','')} ➝ {route.dest.split('(')[1].replace(')','')}</div>
                     <div className="text-xs text-slate-500">{route.dist}</div>
                   </div>
                </div>
                <div className={cn("px-2 py-1 rounded text-xs font-bold", route.load > 90 ? "bg-emerald-100 text-emerald-700" : "bg-blue-100 text-blue-700")}>
                  {route.load}% Load
                </div>
              </div>
              
              <div className="flex justify-between items-center text-xs text-slate-500 border-t border-slate-50 pt-3">
                 <div className="flex items-center">
                   <Clock className="w-3 h-3 mr-1" />
                   {route.time}
                 </div>
                 <div className="flex items-center font-bold text-slate-700">
                   <DollarSign className="w-3 h-3 mr-1" />
                   {route.profit.toLocaleString()} / day
                 </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </div>
  );
}
