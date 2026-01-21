import React from 'react';
import { motion } from 'motion/react';
import { Plane, Battery, Gauge, Wrench, MoreHorizontal, Fuel } from 'lucide-react';
import { cn } from '@/lib/utils';

const fleetData = [
  { id: 1, name: 'Boeing 787-9 Dreamliner', reg: 'N787SK', status: 'In Flight', condition: 92, fuel: 45, nextMaint: '12 Days', image: 'https://images.unsplash.com/photo-1649486927127-8c16f6d175ac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb21tZXJjaWFsJTIwYWlycGxhbmUlMjBmbHlpbmclMjBibHVlJTIwc2t5fGVufDF8fHx8MTc2ODk0NTUwMHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral' },
  { id: 2, name: 'Airbus A320neo', reg: 'N320SK', status: 'Boarding', condition: 98, fuel: 100, nextMaint: '45 Days', image: 'https://images.unsplash.com/photo-1716713954917-5501e188ad89?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhaXJwb3J0JTIwcnVud2F5JTIwdGVybWluYWwlMjBidXN5fGVufDF8fHx8MTc2ODk0NTUwMHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral' },
  { id: 3, name: 'Boeing 737 MAX 8', reg: 'N737SK', status: 'Maintenance', condition: 65, fuel: 10, nextMaint: 'Now', image: 'https://images.unsplash.com/photo-1542296332-2e44a996aa0b?auto=format&fit=crop&q=80&w=1000' },
  { id: 4, name: 'Airbus A350-900', reg: 'N350SK', status: 'Idle', condition: 88, fuel: 80, nextMaint: '20 Days', image: 'https://images.unsplash.com/photo-1559096996-18d2f234567a?auto=format&fit=crop&q=80&w=1000' },
  { id: 5, name: 'Embraer E195-E2', reg: 'N195SK', status: 'In Flight', condition: 95, fuel: 32, nextMaint: '30 Days', image: 'https://images.unsplash.com/photo-1436491865332-7a6153212e7e?auto=format&fit=crop&q=80&w=1000' },
];

export function Fleet() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-slate-800">Fleet Management</h2>
        <button className="bg-blue-600 text-white px-5 py-2 rounded-lg font-medium hover:bg-blue-700 transition-colors shadow-lg shadow-blue-500/30">
          + Purchase Aircraft
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {fleetData.map((plane, index) => (
          <motion.div 
            key={plane.id}
            className="bg-white rounded-2xl overflow-hidden shadow-sm border border-slate-100 hover:shadow-md transition-shadow group"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
          >
            <div className="h-48 overflow-hidden relative">
              <img 
                src={plane.image} 
                alt={plane.name}
                className="w-full h-full object-cover transform group-hover:scale-110 transition-transform duration-500" 
              />
              <div className="absolute top-4 right-4">
                <span className={cn(
                  "px-3 py-1 rounded-full text-xs font-bold shadow-sm backdrop-blur-md",
                  plane.status === 'In Flight' ? "bg-emerald-500/90 text-white" :
                  plane.status === 'Maintenance' ? "bg-red-500/90 text-white" :
                  plane.status === 'Boarding' ? "bg-blue-500/90 text-white" :
                  "bg-slate-500/90 text-white"
                )}>
                  {plane.status}
                </span>
              </div>
            </div>
            
            <div className="p-5">
              <div className="flex justify-between items-start mb-2">
                <div>
                  <h3 className="font-bold text-lg text-slate-800">{plane.name}</h3>
                  <p className="text-slate-500 text-sm font-mono">{plane.reg}</p>
                </div>
                <button className="text-slate-400 hover:text-slate-600">
                  <MoreHorizontal className="w-5 h-5" />
                </button>
              </div>

              <div className="mt-4 space-y-3">
                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center text-slate-600">
                    <Gauge className="w-4 h-4 mr-2" /> Condition
                  </div>
                  <div className="flex items-center space-x-2 w-24">
                    <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                      <div 
                        className={cn("h-full rounded-full", plane.condition > 90 ? "bg-emerald-500" : plane.condition > 70 ? "bg-amber-500" : "bg-red-500")}
                        style={{ width: `${plane.condition}%` }}
                      ></div>
                    </div>
                    <span className="font-bold text-slate-700">{plane.condition}%</span>
                  </div>
                </div>

                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center text-slate-600">
                    <Fuel className="w-4 h-4 mr-2" /> Fuel Level
                  </div>
                   <div className="flex items-center space-x-2 w-24">
                    <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                      <div 
                        className="h-full bg-blue-500 rounded-full"
                        style={{ width: `${plane.fuel}%` }}
                      ></div>
                    </div>
                    <span className="font-bold text-slate-700">{plane.fuel}%</span>
                  </div>
                </div>

                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center text-slate-600">
                    <Wrench className="w-4 h-4 mr-2" /> Maintenance
                  </div>
                  <span className={cn("font-medium", plane.nextMaint === 'Now' ? "text-red-600" : "text-slate-700")}>
                    {plane.nextMaint}
                  </span>
                </div>
              </div>

              <div className="mt-6 pt-4 border-t border-slate-100 flex justify-between items-center">
                 <button className="text-blue-600 text-sm font-medium hover:text-blue-800">View Details</button>
                 <button className="text-slate-500 text-sm font-medium hover:text-slate-700">Schedule Flight</button>
              </div>
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
