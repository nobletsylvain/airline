import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Users, UserPlus, Award, Briefcase, Mail, Phone, MoreHorizontal, Search, Filter } from 'lucide-react';
import { cn } from '@/lib/utils';

const staffMembers = [
  { id: 1, name: 'Sarah Connor', role: 'Chief Pilot', dept: 'Flight Ops', status: 'Active', image: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwb3J0cmFpdCUyMHByb2Zlc3Npb25hbCUyMHdvbWFufGVufDF8fHx8MTc2ODk0NTUwMHww&ixlib=rb-4.1.0&q=80&w=100' },
  { id: 2, name: 'James Rodriguez', role: 'Senior Engineer', dept: 'Maintenance', status: 'On Leave', image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdHxlbnwxfHx8fDE3Njg5NDU1MDB8MA&ixlib=rb-4.1.0&q=80&w=100' },
  { id: 3, name: 'David Kim', role: 'Principal Engineer', dept: 'Maintenance', status: 'Active', image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHRlY2hub2xvZ3l8ZW58MXx8fHwxNzY4OTQ1NTAwfDA&ixlib=rb-4.1.0&q=80&w=100' },
  { id: 4, name: 'Emily Chen', role: 'Flight Attendant Lead', dept: 'Cabin Crew', status: 'Active', image: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHBvcnRyYWl0fGVufDF8fHx8MTc2ODk0NTUwMHww&ixlib=rb-4.1.0&q=80&w=100' },
  { id: 5, name: 'Michael Ross', role: 'Route Planner', dept: 'Operations', status: 'Active', image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMGJ1c2luZXNzfGVufDF8fHx8MTc2ODk0NTUwMHww&ixlib=rb-4.1.0&q=80&w=100' },
  { id: 6, name: 'Jessica Pearson', role: 'Head of Marketing', dept: 'Marketing', status: 'Active', image: 'https://images.unsplash.com/photo-1594744803329-e58b31de8bf5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMGJ1c2luZXNzfGVufDF8fHx8MTc2ODk0NTUwMHww&ixlib=rb-4.1.0&q=80&w=100' },
];

const departments = [
  { name: 'Flight Ops', count: 145, budget: '$1.2M' },
  { name: 'Maintenance', count: 84, budget: '$850k' },
  { name: 'Cabin Crew', count: 320, budget: '$1.5M' },
  { name: 'Ground Ops', count: 210, budget: '$980k' },
  { name: 'Admin & HQ', count: 56, budget: '$2.1M' },
];

export function Staff() {
  const [searchQuery, setSearchQuery] = useState('');
  const [deptFilter, setDeptFilter] = useState('all');

  const filteredStaff = staffMembers.filter(staff => {
    const matchesSearch = staff.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                         staff.role.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesDept = deptFilter === 'all' || staff.dept === deptFilter;
    return matchesSearch && matchesDept;
  });

  const uniqueDepts = ['all', ...Array.from(new Set(staffMembers.map(s => s.dept)))];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Staff Management</h1>
          <p className="text-slate-500 mt-1">Manage your workforce and track employee performance</p>
        </div>
        <div className="flex space-x-3">
          <button className="flex items-center space-x-2 text-slate-600 bg-white border border-slate-200 px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-slate-50 transition-colors">
            <Briefcase className="w-4 h-4" />
            <span>Departments</span>
          </button>
          <button className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-blue-700 transition-all shadow-lg shadow-blue-500/30 hover:shadow-xl">
            <UserPlus className="w-4 h-4" />
            <span>Hire Staff</span>
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
        {departments.map((dept) => (
          <div key={dept.name} className="bg-white p-4 rounded-xl shadow-sm border border-slate-100">
            <div className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">
              {dept.name}
            </div>
            <div className="flex justify-between items-end">
              <div className="text-xl font-bold text-slate-800">{dept.count}</div>
              <div className="text-xs text-emerald-600 font-medium bg-emerald-50 px-2 py-0.5 rounded-full">
                {dept.budget}
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <div className="p-6 border-b border-slate-100">
          <div className="flex justify-between items-center mb-4">
            <div>
              <h3 className="text-lg font-bold text-slate-800">Employee Directory</h3>
              <p className="text-sm text-slate-500 mt-1">Search and filter your staff</p>
            </div>
          </div>
          <div className="flex flex-col md:flex-row gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-5 h-5" />
              <input 
                type="text" 
                placeholder="Search by name or role..." 
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
              />
            </div>
            <select 
              value={deptFilter}
              onChange={(e) => setDeptFilter(e.target.value)}
              className="px-4 py-2.5 rounded-lg border border-slate-200 bg-slate-50 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {uniqueDepts.map(dept => (
                <option key={dept} value={dept}>
                  {dept === 'all' ? 'All Departments' : dept}
                </option>
              ))}
            </select>
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 text-xs uppercase font-semibold text-slate-500">
              <tr>
                <th className="px-6 py-4">Employee</th>
                <th className="px-6 py-4">Role</th>
                <th className="px-6 py-4">Department</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredStaff.map((staff, index) => (
                <motion.tr 
                  key={staff.id} 
                  className="hover:bg-slate-50 transition-colors group cursor-pointer"
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.05 }}
                >
                  <td className="px-6 py-4">
                    <div className="flex items-center space-x-3">
                      <div className="relative">
                        <img src={staff.image} alt={staff.name} className="w-12 h-12 rounded-full object-cover ring-2 ring-slate-200 group-hover:ring-blue-300 transition-all" />
                        {staff.status === 'Active' && (
                          <div className="absolute bottom-0 right-0 w-3 h-3 bg-emerald-500 rounded-full border-2 border-white"></div>
                        )}
                      </div>
                      <div>
                        <div className="font-bold text-slate-900">{staff.name}</div>
                        <div className="text-xs text-slate-400">ID: SKY-{1000 + staff.id}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="font-medium text-slate-800">{staff.role}</div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-800 border border-slate-200">
                      {staff.dept}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span className={cn(
                      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border",
                      staff.status === 'Active' 
                        ? "bg-emerald-50 text-emerald-700 border-emerald-200" 
                        : "bg-amber-50 text-amber-700 border-amber-200"
                    )}>
                      {staff.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex justify-end space-x-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="Send Email">
                        <Mail className="w-4 h-4" />
                      </button>
                      <button className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="Call">
                        <Phone className="w-4 h-4" />
                      </button>
                      <button className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition-colors" title="More Options">
                        <MoreHorizontal className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredStaff.length === 0 && (
          <div className="p-12 text-center">
            <Users className="w-12 h-12 text-slate-300 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-slate-800 mb-2">No employees found</h3>
            <p className="text-slate-500">Try adjusting your search or filter criteria</p>
          </div>
        )}
        <div className="p-4 border-t border-slate-100 flex justify-between items-center bg-slate-50">
          <span className="text-sm text-slate-600">Showing {filteredStaff.length} of {staffMembers.length} employees</span>
          <button className="text-sm font-medium text-blue-600 hover:text-blue-800 transition-colors">
            View All Employees →
          </button>
        </div>
      </div>
    </div>
  );
}
