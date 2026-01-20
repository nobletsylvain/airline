import React from 'react';
import { motion } from 'motion/react';
import { Clock, Plane } from 'lucide-react';

interface LoadGameProps {
  onBack: () => void;
  onLoad: (saveId: string) => void;
}

const SAVES = [
  { id: '1', name: 'Global Wings - Year 5', funds: '$1.2B', date: '2025-10-24 14:30', airline: 'Global Wings' },
  { id: '2', name: 'Budget Air - Year 2', funds: '$45M', date: '2025-10-23 09:15', airline: 'Budget Air' },
  { id: '3', name: 'Cargo Master - Year 8', funds: '$3.5B', date: '2025-10-20 20:45', airline: 'Cargo Master' },
];

export const LoadGame: React.FC<LoadGameProps> = ({ onBack, onLoad }) => {
  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      className="w-full max-w-2xl bg-black/60 backdrop-blur-md p-8 rounded-lg border border-white/10 text-white"
    >
      <h2 className="text-3xl font-bold mb-8 uppercase tracking-widest border-b border-white/20 pb-4">Load Game</h2>
      
      <div className="space-y-4 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
        {SAVES.map((save) => (
          <motion.div 
            key={save.id}
            whileHover={{ scale: 1.02 }}
            onClick={() => onLoad(save.id)}
            className="p-4 bg-white/5 border border-white/10 rounded cursor-pointer hover:bg-white/10 hover:border-white/30 transition-all group"
          >
            <div className="flex justify-between items-center mb-2">
              <span className="font-bold text-lg text-blue-400 group-hover:text-blue-300">{save.name}</span>
              <span className="text-sm text-gray-400">{save.date}</span>
            </div>
            <div className="flex gap-6 text-sm text-gray-300">
              <div className="flex items-center gap-2">
                <Plane className="w-4 h-4" />
                {save.airline}
              </div>
              <div className="flex items-center gap-2">
                <Clock className="w-4 h-4" />
                {save.funds}
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      <div className="mt-8">
        <button 
          onClick={onBack}
          className="px-8 py-3 border border-white/20 hover:bg-white/10 text-white font-bold rounded transition-colors uppercase tracking-wide"
        >
          Back
        </button>
      </div>
    </motion.div>
  );
};
