// src/components/VideoPlayer.tsx
import React, { useCallback } from 'react';
import { formatTime } from '../utils/formatTime';
import { PlayPauseButton } from './UI/PlayPauseButton';
import { useVideoPlayer } from '../hooks/useVideoPlayer'; // Import the hook's return type

interface VideoPlayerProps {
  videoControls: ReturnType<typeof useVideoPlayer>; // Pass the entire hook return
}

export const VideoPlayer: React.FC<VideoPlayerProps> = React.memo(({ videoControls }) => {
  const { videoRef, isPlaying, currentTime, duration, togglePlay, seek, videoLoaded, currentVideoSrc } = videoControls;

  const handleSeekChange = useCallback((event: React.ChangeEvent<HTMLInputElement>) => {
    const time = parseFloat(event.target.value);
    seek(time);
  }, [seek]);

  const currentFormattedTime = formatTime(currentTime);
  const totalFormattedDuration = formatTime(duration);

  return (
    <div className="flex flex-col items-center bg-gray-800 rounded-2xl overflow-hidden shadow-xl p-4 w-full h-full">
      <div className="relative w-full aspect-video bg-black flex items-center justify-center rounded-lg overflow-hidden shadow-lg">
        {currentVideoSrc ? (
          <video
            ref={videoRef}
            className="w-full h-full object-contain"
            onContextMenu={(e) => e.preventDefault()}
            preload="metadata"
          />
        ) : (
          <p className="text-gray-400 text-lg">No video loaded. Upload or use sample.</p>
        )}

        {/* Central Play/Pause button overlay */}
        {videoLoaded && (
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-10">
            <PlayPauseButton
              isPlaying={isPlaying}
              onClick={togglePlay}
              disabled={!videoLoaded}
            />
          </div>
        )}
      </div>

      <div className="flex items-center justify-between w-full mt-4 gap-4 px-2">
        <PlayPauseButton
          isPlaying={isPlaying}
          onClick={togglePlay}
          disabled={!videoLoaded}
          className="hidden sm:flex"
        />

        <span className="text-gray-300 font-mono text-sm min-w-[50px] text-center">{currentFormattedTime}</span>

        <input
          type="range"
          min="0"
          max={duration}
          value={currentTime}
          step="0.01"
          onChange={handleSeekChange}
          className="flex-grow h-2 bg-gray-700 rounded-full appearance-none cursor-pointer
            [&::-webkit-slider-thumb]:w-4 [&::-webkit-slider-thumb]:h-4 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-blue-500 [&::-webkit-slider-thumb]:shadow-lg [&::-webkit-slider-thumb]:-mt-[3px] [&::-webkit-slider-thumb]:relative [&::-webkit-slider-thumb]:z-10
            [&::-moz-range-thumb]:w-4 [&::-moz-range-thumb]:h-4 [&::-moz-range-thumb]:rounded-full [&::-moz-range-thumb]:bg-blue-500 [&::-moz-range-thumb]:border-none [&::-moz-range-thumb]:shadow-lg
            "
          disabled={!videoLoaded || duration === 0}
        />

        <span className="text-gray-300 font-mono text-sm min-w-[50px] text-center">{totalFormattedDuration}</span>
      </div>
    </div>
  );
});