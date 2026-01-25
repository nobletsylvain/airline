import React, { useState } from 'react';
import { motion } from 'motion/react';
import { DollarSign, TrendingUp, TrendingDown, CreditCard, PieChart as PieChartIcon, Download, Calendar, Filter, FileText, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend, LineChart, Line } from 'recharts';
import { cn } from '@/lib/utils';

const monthlyData = [
  { name: 'Jan', income: 450000, expenses: 320000 },
  { name: 'Feb', income: 520000, expenses: 350000 },
  { name: 'Mar', income: 480000, expenses: 340000 },
  { name: 'Apr', income: 610000, expenses: 400000 },
  { name: 'May', income: 590000, expenses: 390000 },
  { name: 'Jun', income: 750000, expenses: 500000 },
];

const expenseData = [
  { name: 'Fuel', value: 450000, color: '#ef4444' },
  { name: 'Maintenance', value: 200000, color: '#f97316' },
  { name: 'Staff Salaries', value: 350000, color: '#3b82f6' },
  { name: 'Airport Fees', value: 150000, color: '#8b5cf6' },
  { name: 'Marketing', value: 80000, color: '#10b981' },
];

const transactions = [
  { id: 1, date: '2026-01-20', desc: 'Fuel Refill - LHR', amount: -12500, type: 'expense' },
  { id: 2, date: '2026-01-20', desc: 'Ticket Sales - Route JFK-LHR', amount: 45200, type: 'income' },
  { id: 3, date: '2026-01-19', desc: 'Maintenance - Boeing 787', amount: -8500, type: 'expense' },
  { id: 4, date: '2026-01-19', desc: 'Cargo Revenue', amount: 15600, type: 'income' },
  { id: 5, date: '2026-01-18', desc: 'Landing Fees - HND', amount: -3200, type: 'expense' },
];

export function Finances() {
  const [timeRange, setTimeRange] = useState('6m');

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Financial Reports</h1>
          <p className="text-slate-500 mt-1">Track revenue, expenses, and profitability</p>
        </div>
        <div className="flex items-center space-x-3">
          <button className="flex items-center space-x-2 text-slate-600 hover:text-slate-900 transition-colors bg-white border border-slate-200 px-4 py-2 rounded-lg text-sm font-medium hover:bg-slate-50">
            <Filter className="w-4 h-4" />
            <span>Filter</span>
          </button>
          <button className="flex items-center space-x-2 text-slate-600 hover:text-slate-900 transition-colors bg-white border border-slate-200 px-4 py-2 rounded-lg text-sm font-medium hover:bg-slate-50">
            <Download className="w-4 h-4" />
            <span>Export</span>
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <FinancialCard 
          title="Net Profit (YTD)" 
          value="$1,240,500" 
          change="+18.2%" 
          isPositive={true} 
          icon={TrendingUp}
          color="bg-emerald-500"
        />
        <FinancialCard 
          title="Operating Expenses" 
          value="$4,850,200" 
          change="+5.1%" 
          isPositive={false} 
          icon={TrendingDown}
          color="bg-red-500"
        />
        <FinancialCard 
          title="Cash on Hand" 
          value="$8,450,000" 
          change="+2.4%" 
          isPositive={true} 
          icon={CreditCard}
          color="bg-blue-500"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <motion.div 
          className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <div className="flex justify-between items-center mb-6">
            <div>
              <h3 className="text-lg font-bold text-slate-800">Income vs Expenses</h3>
              <p className="text-sm text-slate-500 mt-1">Monthly comparison</p>
            </div>
            <select 
              value={timeRange}
              onChange={(e) => setTimeRange(e.target.value)}
              className="px-3 py-1.5 rounded-lg border border-slate-200 bg-slate-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="3m">Last 3 Months</option>
              <option value="6m">Last 6 Months</option>
              <option value="12m">Last Year</option>
            </select>
          </div>
          <div className="h-80 w-full min-h-[320px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={monthlyData} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} tickFormatter={(value) => `$${value/1000}k`} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  cursor={{ fill: '#f1f5f9' }}
                  formatter={(value: number) => `$${value.toLocaleString()}`}
                />
                <Legend iconType="circle" wrapperStyle={{ paddingTop: '20px' }} />
                <Bar dataKey="income" name="Income" fill="#3b82f6" radius={[4, 4, 0, 0]} barSize={30} />
                <Bar dataKey="expenses" name="Expenses" fill="#ef4444" radius={[4, 4, 0, 0]} barSize={30} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        <motion.div 
          className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <div className="mb-6">
            <h3 className="text-lg font-bold text-slate-800">Expense Breakdown</h3>
            <p className="text-sm text-slate-500 mt-1">Current month allocation</p>
          </div>
          <div className="h-80 w-full min-h-[320px]">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={expenseData}
                  cx="50%"
                  cy="50%"
                  innerRadius={70}
                  outerRadius={100}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {expenseData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} stroke="#fff" strokeWidth={2} />
                  ))}
                </Pie>
                <Tooltip 
                   formatter={(value: number) => `$${value.toLocaleString()}`}
                   contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                />
                <Legend 
                  layout="vertical" 
                  verticalAlign="middle" 
                  align="right"
                  iconType="circle"
                  wrapperStyle={{ fontSize: '12px', paddingLeft: '20px' }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-4 pt-4 border-t border-slate-100">
            <div className="flex items-center justify-between text-sm">
              <span className="text-slate-600">Total Expenses</span>
              <span className="font-bold text-slate-900">${expenseData.reduce((sum, e) => sum + e.value, 0).toLocaleString()}</span>
            </div>
          </div>
        </motion.div>
      </div>

      <motion.div 
        className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
      >
        <div className="p-6 border-b border-slate-100 flex justify-between items-center">
          <div>
            <h3 className="text-lg font-bold text-slate-800">Recent Transactions</h3>
            <p className="text-sm text-slate-500 mt-1">Latest financial activity</p>
          </div>
          <button className="text-sm text-blue-600 font-medium hover:text-blue-800 flex items-center space-x-1">
            <span>View All</span>
            <ArrowUpRight className="w-4 h-4" />
          </button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-xs uppercase font-semibold text-slate-500">
              <tr>
                <th className="px-6 py-4">Date</th>
                <th className="px-6 py-4">Description</th>
                <th className="px-6 py-4">Type</th>
                <th className="px-6 py-4 text-right">Amount</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {transactions.map((tx, index) => (
                <motion.tr 
                  key={tx.id} 
                  className="hover:bg-slate-50 transition-colors cursor-pointer"
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.3 + index * 0.05 }}
                >
                  <td className="px-6 py-4 text-slate-600">{tx.date}</td>
                  <td className="px-6 py-4">
                    <div className="font-medium text-slate-900">{tx.desc}</div>
                  </td>
                  <td className="px-6 py-4">
                    <span className={cn(
                      "px-2.5 py-1 rounded-full text-xs font-bold capitalize border",
                      tx.type === 'income' 
                        ? "bg-emerald-50 text-emerald-700 border-emerald-200" 
                        : "bg-red-50 text-red-700 border-red-200"
                    )}>
                      {tx.type}
                    </span>
                  </td>
                  <td className={cn(
                    "px-6 py-4 text-right font-bold text-base",
                    tx.amount > 0 ? "text-emerald-600" : "text-red-600"
                  )}>
                    <div className="flex items-center justify-end space-x-1">
                      {tx.amount > 0 ? (
                        <ArrowUpRight className="w-4 h-4" />
                      ) : (
                        <ArrowDownRight className="w-4 h-4" />
                      )}
                      <span>${Math.abs(tx.amount).toLocaleString()}</span>
                    </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="p-4 border-t border-slate-100 bg-slate-50">
          <div className="flex justify-between items-center text-sm">
            <span className="text-slate-600">Showing 5 of {transactions.length} transactions</span>
            <button className="text-blue-600 font-medium hover:text-blue-800">Load More</button>
          </div>
        </div>
      </motion.div>
    </div>
  );
}

function FinancialCard({ title, value, change, isPositive, icon: Icon, color }: any) {
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
        <div className={cn(
          "flex items-center text-xs font-semibold px-2.5 py-1 rounded-full border",
          isPositive 
            ? "text-emerald-700 bg-emerald-50 border-emerald-200" 
            : "text-red-700 bg-red-50 border-red-200"
        )}>
          {isPositive ? <TrendingUp className="w-3 h-3 mr-1" /> : <TrendingDown className="w-3 h-3 mr-1" />}
          {change}
        </div>
      </div>
      <h3 className="text-slate-500 text-sm font-medium mb-1">{title}</h3>
      <div className="text-3xl font-bold text-slate-900">{value}</div>
    </motion.div>
  );
}
