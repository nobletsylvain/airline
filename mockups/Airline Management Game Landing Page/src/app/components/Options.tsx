import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Volume2, Monitor, Moon } from 'lucide-react';

interface OptionsProps {
  onBack: () => void;
}

export const Options: React.FC<OptionsProps> = ({ onBack }) => {
  const [volume, setVolume] = useState(80);
  const [graphics, setGraphics] = useState('high');

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      className="w-full max-w-2xl bg-black/60 backdrop-blur-md p-8 rounded-lg border border-white/10 text-white"
    >
      <h2 className="text-3xl font-bold mb-8 uppercase tracking-widest border-b border-white/20 pb-4">Settings</h2>
      
      <div className="space-y-8">
        {/* Audio */}
        <div>
          <h3 className="text-xl font-bold mb-4 flex items-center gap-2 text-blue-400">
            <Volume2 className="w-5 h-5" /> Audio
          </h3>
          <div className="flex items-center gap-4">
            <span className="w-24 text-sm font-medium">Master Volume</span>
            <input 
              type="range" 
              min="0" 
              max="100" 
              value={volume}
              onChange={(e) => setVolume(Number(e.target.value))}
              className="flex-1 h-2 bg-gray-700 rounded-lg appearance-none cursor-pointer accent-blue-500"
            />
            <span className="w-12 text-right font-mono">{volume}%</span>
          </div>
        </div>

        {/* Graphics */}
        <div>
          <h3 className="text-xl font-bold mb-4 flex items-center gap-2 text-blue-400">
            <Monitor className="w-5 h-5" /> Graphics
          </h3>
          <div className="flex items-center gap-4">
            <span className="w-24 text-sm font-medium">Quality</span>
            <div className="flex flex-1 gap-2">
              {['low', 'medium', 'high', 'ultra'].map((q) => (
                <button
                  key={q}
                  onClick={() => setGraphics(q)}
                  className={`flex-1 py-2 px-3 rounded text-sm uppercase font-bold transition-all
                    ${graphics === q 
                      ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20' 
                      : 'bg-white/5 text-gray-400 hover:bg-white/10'}
                  `}
                >
                  {q}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="mt-10 pt-6 border-t border-white/10 flex justify-between items-center">
        <button 
          onClick={onBack}
          className="px-8 py-3 border border-white/20 hover:bg-white/10 text-white font-bold rounded transition-colors uppercase tracking-wide"
        >
          Back
        </button>
        <button 
          onClick={onBack}
          className="px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded transition-colors uppercase tracking-wide"
        >
          Apply Changes
        </button>
      </div>
    </motion.div>
  );
};
