// src/components/UI/PlayPauseButton.tsx
import React from 'react';
import { Button } from './Button';

interface PlayPauseButtonProps {
  isPlaying: boolean;
  onClick: () => void;
  disabled?: boolean;
}

export const PlayPauseButton: React.FC<PlayPauseButtonProps> = ({ isPlaying, onClick, disabled }) => {
  return (
    <Button
      onClick={onClick}
      disabled={disabled}
      variant="icon"
      className="bg-white/20 backdrop-blur-sm !p-3 sm:!p-4 text-white text-2xl !rounded-full shadow-lg hover:bg-white/30"
    >
      {isPlaying ? (
        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 sm:h-8 sm:w-8" viewBox="0 0 24 24" fill="currentColor">
          <path fillRule="evenodd" d="M6.75 5.25a.75.75 0 0 1 .75-.75H9a.75.75 0 0 1 .75.75v13.5a.75.75 0 0 1-.75.75H7.5a.75.75 0 0 1-.75-.75V5.25Zm7.5 0a.75.75 0 0 1 .75-.75H16.5a.75.75 0 0 1 .75.75v13.5a.75.75 0 0 1-.75.75H15a.75.75 0 0 1-.75-.75V5.25Z" clipRule="evenodd" />
        </svg>
      ) : (
        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 sm:h-8 sm:w-8" viewBox="0 0 24 24" fill="currentColor">
          <path fillRule="evenodd" d="M4.5 5.653c0-1.427 1.529-2.33 2.779-1.643l11.54 6.347c1.295.712 1.295 2.568 0 3.28L7.28 20.32c-1.25.687-2.779-.235-2.779-1.643V5.653Z" clipRule="evenodd" />
        </svg>
      )}
    </Button>
  );
};