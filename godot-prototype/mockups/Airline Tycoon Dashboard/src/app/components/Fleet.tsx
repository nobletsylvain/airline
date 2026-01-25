import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Plane, Battery, Gauge, Wrench, MoreHorizontal, Fuel, Search, Filter, Grid, List, Plus, AlertTriangle } from 'lucide-react';
import { cn } from '@/lib/utils';

const fleetData = [
  { id: 1, name: 'Boeing 787-9 Dreamliner', reg: 'N787SK', status: 'In Flight', condition: 92, fuel: 45, nextMaint: '12 Days', image: 'https://images.unsplash.com/photo-1649486927127-8c16f6d175ac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb21tZXJjaWFsJTIwYWlycGxhbmUlMjBmbHlpbmclMjBibHVlJTIwc2t5fGVufDF8fHx8MTc2ODk0NTUwMHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral', route: 'LHR → JFK', hours: 12450 },
  { id: 2, name: 'Airbus A320neo', reg: 'N320SK', status: 'Boarding', condition: 98, fuel: 100, nextMaint: '45 Days', image: 'https://images.unsplash.com/photo-1716713954917-5501e188ad89?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhaXJwb3J0JTIwcnVud2F5JTIwdGVybWluYWwlMjBidXN5fGVufDF8fHx8MTc2ODk0NTUwMHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral', route: 'DXB → SIN', hours: 8900 },
  { id: 3, name: 'Boeing 737 MAX 8', reg: 'N737SK', status: 'Maintenance', condition: 65, fuel: 10, nextMaint: 'Now', image: 'https://images.unsplash.com/photo-1542296332-2e44a996aa0b?auto=format&fit=crop&q=80&w=1000', route: 'None', hours: 15200 },
  { id: 4, name: 'Airbus A350-900', reg: 'N350SK', status: 'Idle', condition: 88, fuel: 80, nextMaint: '20 Days', image: 'https://images.unsplash.com/photo-1559096996-18d2f234567a?auto=format&fit=crop&q=80&w=1000', route: 'Available', hours: 6700 },
  { id: 5, name: 'Embraer E195-E2', reg: 'N195SK', status: 'In Flight', condition: 95, fuel: 32, nextMaint: '30 Days', image: 'https://images.unsplash.com/photo-1436491865332-7a6153212e7e?auto=format&fit=crop&q=80&w=1000', route: 'LAX → HND', hours: 4200 },
];

export function Fleet() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');

  const filteredFleet = fleetData.filter(plane => {
    const matchesSearch = plane.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                         plane.reg.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || plane.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const statusOptions = ['all', 'In Flight', 'Boarding', 'Maintenance', 'Idle'];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Fleet Management</h1>
          <p className="text-slate-500 mt-1">Manage your aircraft fleet and monitor their status</p>
        </div>
        <button className="flex items-center space-x-2 bg-blue-600 text-white px-5 py-2.5 rounded-lg font-medium hover:bg-blue-700 transition-all shadow-lg shadow-blue-500/30 hover:shadow-xl">
          <Plus className="w-5 h-5" />
          <span>Purchase Aircraft</span>
        </button>
      </div>

      {/* Filters and Search */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-100">
        <div className="flex flex-col md:flex-row gap-4 items-center">
          <div className="relative flex-1 w-full">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-5 h-5" />
            <input 
              type="text" 
              placeholder="Search by aircraft name or registration..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-slate-200 bg-slate-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
            />
          </div>
          <div className="flex items-center space-x-2">
            <select 
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2.5 rounded-lg border border-slate-200 bg-slate-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {statusOptions.map(status => (
                <option key={status} value={status}>
                  {status === 'all' ? 'All Status' : status}
                </option>
              ))}
            </select>
            <div className="flex items-center bg-slate-100 rounded-lg p-1">
              <button
                onClick={() => setViewMode('grid')}
                className={cn(
                  "p-2 rounded transition-colors",
                  viewMode === 'grid' ? "bg-white text-blue-600 shadow-sm" : "text-slate-600 hover:text-slate-900"
                )}
              >
                <Grid className="w-4 h-4" />
              </button>
              <button
                onClick={() => setViewMode('list')}
                className={cn(
                  "p-2 rounded transition-colors",
                  viewMode === 'list' ? "bg-white text-blue-600 shadow-sm" : "text-slate-600 hover:text-slate-900"
                )}
              >
                <List className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
        <div className="mt-3 flex items-center space-x-2 text-sm text-slate-600">
          <span>Showing {filteredFleet.length} of {fleetData.length} aircraft</span>
        </div>
      </div>

      {viewMode === 'grid' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredFleet.map((plane, index) => (
            <AircraftCard key={plane.id} plane={plane} index={index} />
          ))}
        </div>
      ) : (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="divide-y divide-slate-100">
            {filteredFleet.map((plane, index) => (
              <AircraftListItem key={plane.id} plane={plane} index={index} />
            ))}
          </div>
        </div>
      )}

      {filteredFleet.length === 0 && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 p-12 text-center">
          <Plane className="w-12 h-12 text-slate-300 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-slate-800 mb-2">No aircraft found</h3>
          <p className="text-slate-500">Try adjusting your search or filter criteria</p>
        </div>
      )}
    </div>
  );
}

function AircraftCard({ plane, index }: any) {
  return (
    <motion.div 
      className="bg-white rounded-2xl overflow-hidden shadow-sm border border-slate-100 hover:shadow-lg transition-all group cursor-pointer"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      whileHover={{ y: -4 }}
    >
      <div className="h-48 overflow-hidden relative">
        <img 
          src={plane.image} 
          alt={plane.name}
          className="w-full h-full object-cover transform group-hover:scale-110 transition-transform duration-500" 
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
        <div className="absolute top-4 right-4">
          <span className={cn(
            "px-3 py-1 rounded-full text-xs font-bold shadow-lg backdrop-blur-sm border",
            plane.status === 'In Flight' ? "bg-emerald-500/95 text-white border-emerald-400" :
            plane.status === 'Maintenance' ? "bg-red-500/95 text-white border-red-400" :
            plane.status === 'Boarding' ? "bg-blue-500/95 text-white border-blue-400" :
            "bg-slate-500/95 text-white border-slate-400"
          )}>
            {plane.status}
          </span>
        </div>
        <div className="absolute bottom-4 left-4 right-4">
          <h3 className="font-bold text-lg text-white mb-1">{plane.name}</h3>
          <p className="text-white/90 text-sm font-mono">{plane.reg}</p>
        </div>
      </div>
      
      <div className="p-5">
        <div className="mb-4">
          <div className="flex items-center justify-between text-xs text-slate-500 mb-1">
            <span>Current Route</span>
            <span className="font-mono">{plane.hours.toLocaleString()} hrs</span>
          </div>
          <div className="text-sm font-medium text-slate-700">{plane.route}</div>
        </div>

        <div className="space-y-3">
          <div className="flex items-center justify-between text-sm">
            <div className="flex items-center text-slate-600">
              <Gauge className="w-4 h-4 mr-2 text-slate-400" /> 
              <span>Condition</span>
            </div>
            <div className="flex items-center space-x-2 w-32">
              <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                <motion.div 
                  className={cn("h-full rounded-full", 
                    plane.condition > 90 ? "bg-emerald-500" : 
                    plane.condition > 70 ? "bg-amber-500" : "bg-red-500"
                  )}
                  initial={{ width: 0 }}
                  animate={{ width: `${plane.condition}%` }}
                  transition={{ delay: index * 0.1 + 0.3, duration: 0.5 }}
                />
              </div>
              <span className="font-bold text-slate-700 text-xs min-w-[35px]">{plane.condition}%</span>
            </div>
          </div>

          <div className="flex items-center justify-between text-sm">
            <div className="flex items-center text-slate-600">
              <Fuel className="w-4 h-4 mr-2 text-slate-400" /> 
              <span>Fuel Level</span>
            </div>
            <div className="flex items-center space-x-2 w-32">
              <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                <motion.div 
                  className="h-full bg-blue-500 rounded-full"
                  initial={{ width: 0 }}
                  animate={{ width: `${plane.fuel}%` }}
                  transition={{ delay: index * 0.1 + 0.4, duration: 0.5 }}
                />
              </div>
              <span className="font-bold text-slate-700 text-xs min-w-[35px]">{plane.fuel}%</span>
            </div>
          </div>

          <div className="flex items-center justify-between text-sm">
            <div className="flex items-center text-slate-600">
              <Wrench className={cn("w-4 h-4 mr-2", plane.nextMaint === 'Now' ? "text-red-500" : "text-slate-400")} /> 
              <span>Maintenance</span>
            </div>
            <span className={cn(
              "font-medium text-xs px-2 py-1 rounded-full",
              plane.nextMaint === 'Now' ? "text-red-700 bg-red-50 border border-red-200" : 
              "text-slate-700"
            )}>
              {plane.nextMaint}
            </span>
          </div>
        </div>

        <div className="mt-6 pt-4 border-t border-slate-100 flex justify-between items-center">
          <button className="text-blue-600 text-sm font-semibold hover:text-blue-800 transition-colors">
            View Details →
          </button>
          <button 
            className={cn(
              "text-sm font-medium px-3 py-1.5 rounded-lg transition-colors",
              plane.status === 'Idle' || plane.status === 'Available' 
                ? "bg-blue-600 text-white hover:bg-blue-700" 
                : "text-slate-500 hover:text-slate-700"
            )}
            disabled={plane.status !== 'Idle' && plane.status !== 'Available'}
          >
            {plane.status === 'Idle' || plane.status === 'Available' ? 'Assign Route' : 'Unavailable'}
          </button>
        </div>
      </div>
    </motion.div>
  );
}

function AircraftListItem({ plane, index }: any) {
  return (
    <motion.div
      className="p-6 hover:bg-slate-50 transition-colors cursor-pointer"
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: index * 0.05 }}
    >
      <div className="flex items-center space-x-6">
        <div className="relative w-24 h-24 rounded-xl overflow-hidden flex-shrink-0">
          <img src={plane.image} alt={plane.name} className="w-full h-full object-cover" />
          <div className="absolute top-2 right-2">
            <span className={cn(
              "px-2 py-0.5 rounded-full text-xs font-bold backdrop-blur-sm",
              plane.status === 'In Flight' ? "bg-emerald-500/90 text-white" :
              plane.status === 'Maintenance' ? "bg-red-500/90 text-white" :
              plane.status === 'Boarding' ? "bg-blue-500/90 text-white" :
              "bg-slate-500/90 text-white"
            )}>
              {plane.status}
            </span>
          </div>
        </div>
        <div className="flex-1 grid grid-cols-5 gap-4 items-center">
          <div>
            <h3 className="font-bold text-slate-900">{plane.name}</h3>
            <p className="text-slate-500 text-sm font-mono">{plane.reg}</p>
          </div>
          <div>
            <p className="text-xs text-slate-500 mb-1">Route</p>
            <p className="text-sm font-medium text-slate-700">{plane.route}</p>
          </div>
          <div>
            <p className="text-xs text-slate-500 mb-1">Condition</p>
            <div className="flex items-center space-x-2">
              <div className="h-2 w-20 bg-slate-100 rounded-full overflow-hidden">
                <div className={cn("h-full rounded-full", 
                  plane.condition > 90 ? "bg-emerald-500" : 
                  plane.condition > 70 ? "bg-amber-500" : "bg-red-500"
                )} style={{ width: `${plane.condition}%` }} />
              </div>
              <span className="text-sm font-bold text-slate-700">{plane.condition}%</span>
            </div>
          </div>
          <div>
            <p className="text-xs text-slate-500 mb-1">Fuel</p>
            <div className="flex items-center space-x-2">
              <div className="h-2 w-20 bg-slate-100 rounded-full overflow-hidden">
                <div className="h-full bg-blue-500 rounded-full" style={{ width: `${plane.fuel}%` }} />
              </div>
              <span className="text-sm font-bold text-slate-700">{plane.fuel}%</span>
            </div>
          </div>
          <div className="flex items-center justify-end space-x-2">
            <button className="text-blue-600 text-sm font-semibold hover:text-blue-800">Details</button>
            <button className="text-slate-400 hover:text-slate-600">
              <MoreHorizontal className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </motion.div>
  );
}
    </div>
  );
}
