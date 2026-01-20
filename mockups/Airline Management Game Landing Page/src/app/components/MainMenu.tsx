import React from 'react';
import { motion } from 'motion/react';
import { MenuButton } from './MenuButton';
import { Plane } from 'lucide-react';

interface MainMenuProps {
  onSelect: (option: string) => void;
}

export const MainMenu: React.FC<MainMenuProps> = ({ onSelect }) => {
  const containerVariants = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.3
      }
    }
  };

  const itemVariants = {
    hidden: { x: -50, opacity: 0 },
    show: { x: 0, opacity: 1 }
  };

  return (
    <div className="flex flex-col h-full justify-center px-16 z-10 relative">
      <motion.div
        initial={{ y: -50, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.8, ease: "easeOut" }}
        className="mb-12"
      >
        <div className="flex items-center gap-4 mb-2">
          <Plane className="w-12 h-12 text-blue-500 rotate-[-45deg]" />
          <h2 className="text-blue-400 font-bold tracking-[0.2em] text-sm uppercase">Airline Management Sim</h2>
        </div>
        <h1 className="text-7xl font-black text-white uppercase tracking-tighter leading-none">
          Sky<span className="text-blue-500">Tycoon</span>
        </h1>
        <p className="text-gray-400 mt-4 max-w-md text-lg">
          Build your fleet. Manage routes. Conquer the skies.
        </p>
      </motion.div>

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="show"
        className="flex flex-col gap-4"
      >
        <motion.div variants={itemVariants}>
          <MenuButton onClick={() => onSelect('new-game')}>Start New Game</MenuButton>
        </motion.div>
        <motion.div variants={itemVariants}>
          <MenuButton onClick={() => onSelect('load-game')}>Load Game</MenuButton>
        </motion.div>
        <motion.div variants={itemVariants}>
          <MenuButton onClick={() => onSelect('options')}>Options</MenuButton>
        </motion.div>
        <motion.div variants={itemVariants}>
          <MenuButton onClick={() => onSelect('quit')}>Quit</MenuButton>
        </motion.div>
      </motion.div>
      
      <div className="absolute bottom-8 left-16 text-gray-500 text-sm font-mono">
        v1.0.4-beta • Build 2026.01.20
      </div>
    </div>
  );
};
