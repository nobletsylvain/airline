import React from 'react';
import { motion } from 'motion/react';
import { LogOut } from 'lucide-react';

interface QuitProps {
  onCancel: () => void;
  onConfirm: () => void;
}

export const Quit: React.FC<QuitProps> = ({ onCancel, onConfirm }) => {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.9 }}
      className="w-full max-w-md bg-black/80 backdrop-blur-md p-8 rounded-lg border border-red-500/30 text-white text-center shadow-2xl shadow-red-900/20"
    >
      <div className="mx-auto w-16 h-16 bg-red-500/20 rounded-full flex items-center justify-center mb-6">
        <LogOut className="w-8 h-8 text-red-400" />
      </div>
      
      <h2 className="text-2xl font-bold mb-2 uppercase tracking-wide">Quit Game?</h2>
      <p className="text-gray-400 mb-8">Unsaved progress will be lost.</p>
      
      <div className="flex gap-4">
        <button 
          onClick={onCancel}
          className="flex-1 px-6 py-3 bg-white/10 hover:bg-white/20 text-white font-bold rounded transition-colors uppercase tracking-wide"
        >
          Cancel
        </button>
        <button 
          onClick={onConfirm}
          className="flex-1 px-6 py-3 bg-red-600 hover:bg-red-700 text-white font-bold rounded transition-colors uppercase tracking-wide"
        >
          Quit
        </button>
      </div>
    </motion.div>
  );
};
