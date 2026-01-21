import React from 'react';
import { motion } from 'motion/react';
import { Plane, MapPin, DollarSign } from 'lucide-react';

interface NewGameProps {
  onBack: () => void;
  onStart: (settings: any) => void;
}

export const NewGame: React.FC<NewGameProps> = ({ onBack, onStart }) => {
  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      className="w-full max-w-2xl bg-black/60 backdrop-blur-md p-8 rounded-lg border border-white/10 text-white"
    >
      <h2 className="text-3xl font-bold mb-8 uppercase tracking-widest border-b border-white/20 pb-4">Start New Airline</h2>
      
      <div className="space-y-6">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">Airline Name</label>
          <div className="relative">
            <Plane className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input 
              type="text" 
              className="w-full bg-white/5 border border-white/10 rounded-md py-3 pl-10 pr-4 text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="e.g. SkyHigh Airways"
              defaultValue="Global Wings"
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">Hub Airport</label>
          <div className="relative">
            <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <select className="w-full bg-white/5 border border-white/10 rounded-md py-3 pl-10 pr-4 text-white focus:outline-none focus:ring-2 focus:ring-blue-500 appearance-none">
              <option className="text-black" value="LHR">London Heathrow (LHR)</option>
              <option className="text-black" value="JFK">New York (JFK)</option>
              <option className="text-black" value="DXB">Dubai International (DXB)</option>
              <option className="text-black" value="HND">Tokyo Haneda (HND)</option>
              <option className="text-black" value="SIN">Singapore Changi (SIN)</option>
            </select>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">Starting Budget</label>
          <div className="relative">
            <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <select className="w-full bg-white/5 border border-white/10 rounded-md py-3 pl-10 pr-4 text-white focus:outline-none focus:ring-2 focus:ring-blue-500 appearance-none">
              <option className="text-black" value="easy">Easy ($500M)</option>
              <option className="text-black" value="medium">Medium ($100M)</option>
              <option className="text-black" value="hard">Hard ($10M)</option>
            </select>
          </div>
        </div>
      </div>

      <div className="flex gap-4 mt-10">
        <button 
          onClick={onBack}
          className="flex-1 px-6 py-3 border border-white/20 hover:bg-white/10 text-white font-bold rounded transition-colors uppercase tracking-wide"
        >
          Cancel
        </button>
        <button 
          onClick={() => onStart({})}
          className="flex-1 px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded transition-colors uppercase tracking-wide"
        >
          Take Off
        </button>
      </div>
    </motion.div>
  );
};
