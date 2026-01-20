import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { MainMenu } from './components/MainMenu';
import { NewGame } from './components/NewGame';
import { LoadGame } from './components/LoadGame';
import { Options } from './components/Options';
import { Quit } from './components/Quit';

// Using the Unsplash image found earlier
const BACKGROUND_IMAGE = "https://images.unsplash.com/photo-1547024842-5fe343721d1f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhaXJsaW5lJTIwY29ja3BpdCUyMGNsb3VkcyUyMHNreXxlbnwxfHx8fDE3Njg5NDU4NTJ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral";

type Screen = 'menu' | 'new-game' | 'load-game' | 'options' | 'quit' | 'playing';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('menu');

  const handleStartGame = (settings: any) => {
    console.log("Starting game with settings:", settings);
    setCurrentScreen('playing');
  };

  const handleLoadGame = (saveId: string) => {
    console.log("Loading save:", saveId);
    setCurrentScreen('playing');
  };

  const handleQuitConfirm = () => {
    // In a web app, we can't really "quit", so we'll just reset or show a message.
    alert("Thanks for playing!");
    setCurrentScreen('menu');
  };

  return (
    <div className="relative w-full h-screen overflow-hidden bg-black text-white font-sans selection:bg-blue-500 selection:text-white">
      {/* Background Layer */}
      <div 
        className="absolute inset-0 z-0"
        style={{
          backgroundImage: `url(${BACKGROUND_IMAGE})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="absolute inset-0 bg-gradient-to-r from-black/90 via-black/50 to-transparent" />
      </div>

      {/* Content Layer */}
      <div className="relative z-10 w-full h-full flex items-center justify-start">
        <AnimatePresence mode="wait">
          {currentScreen === 'menu' && (
            <motion.div 
              key="menu"
              className="w-full h-full"
              exit={{ opacity: 0, x: -50 }}
            >
              <MainMenu onSelect={(screen) => setCurrentScreen(screen as Screen)} />
            </motion.div>
          )}

          {currentScreen === 'new-game' && (
            <div key="new-game" className="w-full h-full flex items-center justify-center p-8 bg-black/40 backdrop-blur-sm">
              <NewGame onBack={() => setCurrentScreen('menu')} onStart={handleStartGame} />
            </div>
          )}

          {currentScreen === 'load-game' && (
            <div key="load-game" className="w-full h-full flex items-center justify-center p-8 bg-black/40 backdrop-blur-sm">
              <LoadGame onBack={() => setCurrentScreen('menu')} onLoad={handleLoadGame} />
            </div>
          )}

          {currentScreen === 'options' && (
            <div key="options" className="w-full h-full flex items-center justify-center p-8 bg-black/40 backdrop-blur-sm">
              <Options onBack={() => setCurrentScreen('menu')} />
            </div>
          )}

          {currentScreen === 'quit' && (
            <div key="quit" className="w-full h-full flex items-center justify-center p-8 bg-black/40 backdrop-blur-sm">
              <Quit onCancel={() => setCurrentScreen('menu')} onConfirm={handleQuitConfirm} />
            </div>
          )}

          {currentScreen === 'playing' && (
            <motion.div 
              key="playing" 
              initial={{ opacity: 0 }} 
              animate={{ opacity: 1 }} 
              className="w-full h-full bg-white text-black p-8"
            >
              <div className="max-w-4xl mx-auto text-center mt-20">
                <h1 className="text-4xl font-bold mb-4">Simulation Started</h1>
                <p className="mb-8 text-gray-600">This is where the main game interface would be.</p>
                <button 
                  onClick={() => setCurrentScreen('menu')}
                  className="px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700"
                >
                  Return to Main Menu
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Vignette effect */}
      <div className="absolute inset-0 z-20 pointer-events-none bg-[radial-gradient(circle_at_center,transparent_0%,rgba(0,0,0,0.4)_100%)]" />
    </div>
  );
}
