import React from 'react';
import { motion } from 'motion/react';
import { TrendingUp, Users, Plane, DollarSign, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { cn } from '@/lib/utils';

const data = [
  { name: 'Mon', revenue: 4000 },
  { name: 'Tue', revenue: 3000 },
  { name: 'Wed', revenue: 2000 },
  { name: 'Thu', revenue: 2780 },
  { name: 'Fri', revenue: 1890 },
  { name: 'Sat', revenue: 2390 },
  { name: 'Sun', revenue: 3490 },
  { name: 'Mon', revenue: 4200 },
  { name: 'Tue', revenue: 4800 },
  { name: 'Wed', revenue: 5100 },
  { name: 'Thu', revenue: 5800 },
  { name: 'Fri', revenue: 6500 },
  { name: 'Sat', revenue: 7200 },
  { name: 'Sun', revenue: 7800 },
];

export function Overview() {
  return (
    <div className="space-y-6">
      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <KpiCard 
          title="Total Revenue" 
          value="$2,450,230" 
          change="+12.5%" 
          isPositive={true} 
          icon={DollarSign}
          color="bg-emerald-500"
        />
        <KpiCard 
          title="Total Flights" 
          value="1,234" 
          change="+8.2%" 
          isPositive={true} 
          icon={Plane}
          color="bg-blue-500"
        />
        <KpiCard 
          title="Passengers" 
          value="85,302" 
          change="+24.3%" 
          isPositive={true} 
          icon={Users}
          color="bg-indigo-500"
        />
        <KpiCard 
          title="Fuel Costs" 
          value="$890,120" 
          change="+5.4%" 
          isPositive={false} 
          icon={TrendingUp}
          color="bg-amber-500"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Chart */}
        <motion.div 
          className="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-100"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-slate-800">Revenue Analysis</h3>
            <select className="bg-slate-50 border border-slate-200 text-slate-700 text-sm rounded-lg p-2.5 focus:ring-blue-500 focus:border-blue-500">
              <option>Last 14 Days</option>
              <option>Last Month</option>
              <option>Last Year</option>
            </select>
          </div>
          <div className="h-80 w-full min-h-[320px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} tickFormatter={(value) => `$${value}`} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  itemStyle={{ color: '#1e293b', fontWeight: 600 }}
                />
                <Area type="monotone" dataKey="revenue" stroke="#3b82f6" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Live Flights / Activity */}
        <motion.div 
          className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <h3 className="text-lg font-bold text-slate-800 mb-4">Live Flight Status</h3>
          <div className="space-y-4">
            <FlightStatusRow 
              code="SKY-102" 
              origin="LHR" 
              dest="JFK" 
              status="In Air" 
              color="text-emerald-600 bg-emerald-50"
              time="4h 23m remaining"
            />
            <FlightStatusRow 
              code="SKY-405" 
              origin="DXB" 
              dest="SIN" 
              status="Boarding" 
              color="text-blue-600 bg-blue-50"
              time="Departs in 15m"
            />
            <FlightStatusRow 
              code="SKY-891" 
              origin="LAX" 
              dest="HND" 
              status="Delayed" 
              color="text-amber-600 bg-amber-50"
              time="+45m delay"
            />
            <FlightStatusRow 
              code="SKY-223" 
              origin="CDG" 
              dest="AMS" 
              status="Landed" 
              color="text-slate-600 bg-slate-100"
              time="Arrived 10:45"
            />
             <FlightStatusRow 
              code="SKY-777" 
              origin="SYD" 
              dest="LAX" 
              status="In Air" 
              color="text-emerald-600 bg-emerald-50"
              time="9h 10m remaining"
            />
          </div>
          <button className="w-full mt-6 py-2.5 text-sm font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors">
            View All Flights
          </button>
        </motion.div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <motion.div 
          className="bg-gradient-to-br from-indigo-600 to-blue-700 rounded-2xl p-6 text-white relative overflow-hidden"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          <div className="relative z-10">
            <h3 className="text-lg font-bold mb-1">Company Valuation</h3>
            <p className="text-indigo-200 text-sm mb-6">Updated today based on assets & revenue</p>
            <div className="text-4xl font-bold mb-2">$42.8 Million</div>
            <div className="flex items-center text-indigo-100 text-sm">
              <ArrowUpRight className="w-4 h-4 mr-1" />
              <span>+15% from last quarter</span>
            </div>
          </div>
          <div className="absolute right-0 bottom-0 opacity-10 transform translate-x-10 translate-y-10">
            <Plane className="w-64 h-64" />
          </div>
        </motion.div>

        <motion.div 
          className="bg-white p-0 rounded-2xl shadow-sm border border-slate-100 overflow-hidden relative"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
            <img 
                src="https://images.unsplash.com/photo-1731700128691-16fcc9043d11?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b3JsZCUyMG1hcCUyMHZlY3RvciUyMGFic3RyYWN0JTIwYmx1ZXxlbnwxfHx8fDE3Njg5NDU1MDB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" 
                alt="Route Map" 
                className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent flex flex-col justify-end p-6">
                <h3 className="text-white font-bold text-lg">Global Operations</h3>
                <p className="text-slate-200 text-sm">34 Destinations in 12 Countries</p>
            </div>
        </motion.div>
      </div>
    </div>
  );
}

function KpiCard({ title, value, change, isPositive, icon: Icon, color }: any) {
  return (
    <motion.div 
      className="bg-white p-5 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-shadow"
      whileHover={{ y: -2 }}
    >
      <div className="flex justify-between items-start mb-4">
        <div className={cn("p-3 rounded-xl", color, "bg-opacity-10")}>
          <Icon className={cn("w-6 h-6", color.replace('bg-', 'text-'))} />
        </div>
        <div className={cn("flex items-center text-xs font-semibold px-2 py-1 rounded-full", isPositive ? "text-emerald-600 bg-emerald-50" : "text-red-600 bg-red-50")}>
          {isPositive ? <ArrowUpRight className="w-3 h-3 mr-1" /> : <ArrowDownRight className="w-3 h-3 mr-1" />}
          {change}
        </div>
      </div>
      <h3 className="text-slate-500 text-sm font-medium mb-1">{title}</h3>
      <div className="text-2xl font-bold text-slate-800">{value}</div>
    </motion.div>
  );
}

function FlightStatusRow({ code, origin, dest, status, color, time }: any) {
  return (
    <div className="flex items-center justify-between p-3 hover:bg-slate-50 rounded-lg transition-colors border border-transparent hover:border-slate-100">
      <div className="flex items-center space-x-4">
        <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center">
          <Plane className="w-5 h-5 text-slate-500" />
        </div>
        <div>
          <div className="font-bold text-slate-800">{code}</div>
          <div className="text-xs text-slate-500 font-medium">{origin} ✈ {dest}</div>
        </div>
      </div>
      <div className="text-right">
        <span className={cn("text-xs font-bold px-2 py-1 rounded-full", color)}>
          {status}
        </span>
        <div className="text-xs text-slate-400 mt-1">{time}</div>
      </div>
    </div>
  );
}
