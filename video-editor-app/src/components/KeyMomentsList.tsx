// src/components/KeyMomentsList.tsx
import React, { useCallback } from 'react';
import { formatTime } from '../utils/formatTime';
import { KeyMoment } from './Shared.types';
import { Button } from './UI/Button';

interface KeyMomentsListProps {
  keyMoments: KeyMoment[];
  onSeek: (time: number) => void;
  videoLoaded: boolean;
}

export const KeyMomentsList: React.FC<KeyMomentsListProps> = React.memo(({ keyMoments, onSeek, videoLoaded }) => {
  const handleKeyMomentClick = useCallback((timestamp: number) => {
    if (videoLoaded) {
      onSeek(timestamp);
    }
  }, [onSeek, videoLoaded]);

  if (keyMoments.length === 0) {
    return (
      <div className="text-center text-gray-400">
        No key moments found.
      </div>
    );
  }

  return (
    <div className="w-full bg-gray-800 rounded-2xl p-4 shadow-xl overflow-y-auto max-h-80 custom-scrollbar">
      <h2 className="text-xl font-bold text-gray-200 mb-4">Key Moments</h2>
      <ul className="space-y-3">
        {keyMoments.map(moment => (
          <li
            key={moment.id}
            className="flex items-center justify-between p-3 bg-gray-900 rounded-xl shadow-inner transition-all duration-200 hover:bg-gray-700"
          >
            <span className="text-gray-300 text-base font-medium truncate">{moment.title}</span>
            <Button
              onClick={() => handleKeyMomentClick(moment.timestamp)}
              variant="ghost"
              className="ml-4 flex-shrink-0 !text-sm text-blue-400 hover:text-blue-200"
              disabled={!videoLoaded}
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 mr-1" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4.053a1 1 0 001.555.832l3.044-2.027a1 1 0 000-1.664l-3.044-2.027z" clipRule="evenodd" />
              </svg>
              {formatTime(moment.timestamp)}
            </Button>
          </li>
        ))}
      </ul>
      <style jsx>{`
        .custom-scrollbar::-webkit-scrollbar {
          width: 8px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: #1f2937; /* gray-900 */
          border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background-color: #4a5568; /* gray-600 */
          border-radius: 4px;
          border: 2px solid #1f2937;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background-color: #646b77; /* gray-500 hover */
        }
      `}</style>
    </div>
  );
});