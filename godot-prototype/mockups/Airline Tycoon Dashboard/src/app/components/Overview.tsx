import React, { useState } from 'react';
import { motion } from 'motion/react';
import { TrendingUp, Users, Plane, DollarSign, ArrowUpRight, ArrowDownRight, Calendar, Filter, RefreshCw } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import { cn } from '@/lib/utils';

const data = [
  { name: 'Mon', revenue: 4000, profit: 1200 },
  { name: 'Tue', revenue: 3000, profit: 800 },
  { name: 'Wed', revenue: 2000, profit: 500 },
  { name: 'Thu', revenue: 2780, profit: 780 },
  { name: 'Fri', revenue: 1890, profit: 390 },
  { name: 'Sat', revenue: 2390, profit: 590 },
  { name: 'Sun', revenue: 3490, profit: 890 },
  { name: 'Mon', revenue: 4200, profit: 1200 },
  { name: 'Tue', revenue: 4800, profit: 1800 },
  { name: 'Wed', revenue: 5100, profit: 2100 },
  { name: 'Thu', revenue: 5800, profit: 2800 },
  { name: 'Fri', revenue: 6500, profit: 3500 },
  { name: 'Sat', revenue: 7200, profit: 4200 },
  { name: 'Sun', revenue: 7800, profit: 4800 },
];

export function Overview() {
  const [timeRange, setTimeRange] = useState('14d');

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Dashboard Overview</h1>
          <p className="text-slate-500 mt-1">Welcome back! Here's what's happening with your airline today.</p>
        </div>
        <div className="flex items-center space-x-3">
          <button className="flex items-center space-x-2 px-4 py-2 bg-white border border-slate-200 rounded-lg text-sm font-medium text-slate-700 hover:bg-slate-50 transition-colors">
            <Filter className="w-4 h-4" />
            <span>Filter</span>
          </button>
          <button className="flex items-center space-x-2 px-4 py-2 bg-white border border-slate-200 rounded-lg text-sm font-medium text-slate-700 hover:bg-slate-50 transition-colors">
            <RefreshCw className="w-4 h-4" />
            <span>Refresh</span>
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <KpiCard 
          title="Total Revenue" 
          value="$2,450,230" 
          change="+12.5%" 
          isPositive={true} 
          icon={DollarSign}
          color="bg-emerald-500"
          subtitle="Last 30 days"
        />
        <KpiCard 
          title="Total Flights" 
          value="1,234" 
          change="+8.2%" 
          isPositive={true} 
          icon={Plane}
          color="bg-blue-500"
          subtitle="Active routes"
        />
        <KpiCard 
          title="Passengers" 
          value="85,302" 
          change="+24.3%" 
          isPositive={true} 
          icon={Users}
          color="bg-indigo-500"
          subtitle="This month"
        />
        <KpiCard 
          title="Fuel Costs" 
          value="$890,120" 
          change="+5.4%" 
          isPositive={false} 
          icon={TrendingUp}
          color="bg-amber-500"
          subtitle="Operating expense"
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
            <div>
              <h3 className="text-lg font-bold text-slate-800">Revenue & Profit Analysis</h3>
              <p className="text-sm text-slate-500 mt-1">Track your financial performance over time</p>
            </div>
            <div className="flex items-center space-x-2">
              <select 
                value={timeRange}
                onChange={(e) => setTimeRange(e.target.value)}
                className="bg-slate-50 border border-slate-200 text-slate-700 text-sm rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
              >
                <option value="7d">Last 7 Days</option>
                <option value="14d">Last 14 Days</option>
                <option value="30d">Last Month</option>
                <option value="90d">Last Quarter</option>
                <option value="365d">Last Year</option>
              </select>
            </div>
          </div>
          <div className="h-80 w-full min-h-[320px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                  </linearGradient>
                  <linearGradient id="colorProfit" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} tickFormatter={(value) => `$${value}`} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  itemStyle={{ color: '#1e293b', fontWeight: 600 }}
                  formatter={(value: number) => `$${value.toLocaleString()}`}
                />
                <Area type="monotone" dataKey="revenue" stroke="#3b82f6" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
                <Area type="monotone" dataKey="profit" stroke="#10b981" strokeWidth={2} fillOpacity={1} fill="url(#colorProfit)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
          <div className="flex items-center justify-center space-x-6 mt-4 pt-4 border-t border-slate-100">
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 rounded-full bg-blue-500"></div>
              <span className="text-sm text-slate-600">Revenue</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 rounded-full bg-emerald-500"></div>
              <span className="text-sm text-slate-600">Profit</span>
            </div>
          </div>
        </motion.div>

        {/* Live Flights / Activity */}
        <motion.div 
          className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <div className="flex justify-between items-center mb-4">
            <div>
              <h3 className="text-lg font-bold text-slate-800">Live Flight Status</h3>
              <p className="text-xs text-slate-500 mt-1">5 active flights</p>
            </div>
            <div className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse"></div>
          </div>
          <div className="space-y-3 flex-1 overflow-y-auto max-h-[400px]">
            <FlightStatusRow 
              code="SKY-102" 
              origin="LHR" 
              dest="JFK" 
              status="In Air" 
              color="text-emerald-600 bg-emerald-50 border-emerald-200"
              time="4h 23m remaining"
              progress={65}
            />
            <FlightStatusRow 
              code="SKY-405" 
              origin="DXB" 
              dest="SIN" 
              status="Boarding" 
              color="text-blue-600 bg-blue-50 border-blue-200"
              time="Departs in 15m"
              progress={0}
            />
            <FlightStatusRow 
              code="SKY-891" 
              origin="LAX" 
              dest="HND" 
              status="Delayed" 
              color="text-amber-600 bg-amber-50 border-amber-200"
              time="+45m delay"
              progress={20}
            />
            <FlightStatusRow 
              code="SKY-223" 
              origin="CDG" 
              dest="AMS" 
              status="Landed" 
              color="text-slate-600 bg-slate-100 border-slate-200"
              time="Arrived 10:45"
              progress={100}
            />
            <FlightStatusRow 
              code="SKY-777" 
              origin="SYD" 
              dest="LAX" 
              status="In Air" 
              color="text-emerald-600 bg-emerald-50 border-emerald-200"
              time="9h 10m remaining"
              progress={35}
            />
          </div>
          <button className="w-full mt-4 py-2.5 text-sm font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors border border-blue-200">
            View All Flights →
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

function KpiCard({ title, value, change, isPositive, icon: Icon, color, subtitle }: any) {
  return (
    <motion.div 
      className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-all group cursor-pointer"
      whileHover={{ y: -4, scale: 1.02 }}
      transition={{ duration: 0.2 }}
    >
      <div className="flex justify-between items-start mb-4">
        <div className={cn("p-3 rounded-xl transition-transform group-hover:scale-110", color, "bg-opacity-10")}>
          <Icon className={cn("w-6 h-6", color.replace('bg-', 'text-'))} />
        </div>
        <div className={cn("flex items-center text-xs font-semibold px-2.5 py-1 rounded-full border", 
          isPositive ? "text-emerald-700 bg-emerald-50 border-emerald-200" : "text-red-700 bg-red-50 border-red-200"
        )}>
          {isPositive ? <ArrowUpRight className="w-3 h-3 mr-1" /> : <ArrowDownRight className="w-3 h-3 mr-1" />}
          {change}
        </div>
      </div>
      <h3 className="text-slate-500 text-sm font-medium mb-1">{title}</h3>
      <div className="text-3xl font-bold text-slate-900 mb-1">{value}</div>
      {subtitle && <p className="text-xs text-slate-400">{subtitle}</p>}
    </motion.div>
  );
}

function FlightStatusRow({ code, origin, dest, status, color, time, progress }: any) {
  return (
    <motion.div 
      className="flex items-center justify-between p-4 hover:bg-slate-50 rounded-xl transition-all border cursor-pointer group"
      whileHover={{ x: 4 }}
      style={{ borderColor: 'inherit' }}
    >
      <div className="flex items-center space-x-4 flex-1">
        <div className="relative">
          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-50 to-indigo-50 flex items-center justify-center group-hover:scale-110 transition-transform">
            <Plane className="w-6 h-6 text-blue-600 transform -rotate-45" />
          </div>
          {progress !== undefined && progress > 0 && progress < 100 && (
            <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-emerald-500 rounded-full border-2 border-white animate-pulse"></div>
          )}
        </div>
        <div className="flex-1">
          <div className="font-bold text-slate-900 text-sm">{code}</div>
          <div className="text-xs text-slate-500 font-medium mt-0.5">{origin} → {dest}</div>
          {progress !== undefined && progress > 0 && progress < 100 && (
            <div className="mt-2 h-1 bg-slate-100 rounded-full overflow-hidden">
              <motion.div 
                className="h-full bg-blue-500 rounded-full"
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.5 }}
              />
            </div>
          )}
        </div>
      </div>
      <div className="text-right ml-4">
        <span className={cn("text-xs font-bold px-2.5 py-1 rounded-full border inline-block mb-1", color)}>
          {status}
        </span>
        <div className="text-xs text-slate-500 font-medium">{time}</div>
      </div>
    </motion.div>
  );
}
