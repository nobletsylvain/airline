import React from 'react';
import { motion } from 'motion/react';

interface MenuButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  isActive?: boolean;
}

export const MenuButton: React.FC<MenuButtonProps> = ({ children, isActive, className, ...props }) => {
  return (
    <motion.button
      whileHover={{ scale: 1.05, x: 10 }}
      whileTap={{ scale: 0.95 }}
      className={`
        w-full max-w-md px-8 py-4 text-left text-2xl font-bold uppercase tracking-widest
        transition-colors duration-200 border-l-4
        ${isActive 
          ? 'border-blue-500 text-blue-400 bg-blue-500/10' 
          : 'border-transparent text-white/70 hover:text-white hover:bg-white/5 hover:border-white/50'}
        ${className}
      `}
      {...props}
    >
      {children}
    </motion.button>
  );
};
