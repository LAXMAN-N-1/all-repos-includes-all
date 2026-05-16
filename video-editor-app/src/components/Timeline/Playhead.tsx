// src/components/Timeline/Playhead.tsx
import React, { useRef, useCallback, useEffect, useState } from 'react';
import { calculatePosition } from './TimelineUtils';
import { formatTime } from '../../utils/formatTime';

interface PlayheadProps {
  currentTime: number;
  duration: number;
  timelineWidthPx: number;
  onSeek: (time: number) => void;
  videoLoaded: boolean;
}

export const Playhead: React.FC<PlayheadProps> = React.memo(({ currentTime, duration, timelineWidthPx, onSeek, videoLoaded }) => {
  const playheadRef = useRef<HTMLDivElement>(null);
  const [isDragging, setIsDragging] = useState(false);
  const animationFrameRef = useRef<number | null>(null);

  const leftPx = calculatePosition(currentTime, duration, timelineWidthPx);

  const handleMouseMove = useCallback((e: MouseEvent) => {
    if (!isDragging || !playheadRef.current || duration === 0 || !videoLoaded) return;

    if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
    }

    animationFrameRef.current = requestAnimationFrame(() => {
        const timelineRect = playheadRef.current!.parentElement?.getBoundingClientRect();
        if (!timelineRect) return;

        const mouseX = e.clientX;
        const relativeX = mouseX - timelineRect.left;

        const clampedX = Math.max(0, Math.min(relativeX, timelineWidthPx));

        const newTime = (clampedX / timelineWidthPx) * duration;
        onSeek(newTime);
    });
  }, [isDragging, duration, timelineWidthPx, onSeek, videoLoaded]);

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
    document.removeEventListener('mousemove', handleMouseMove);
    document.removeEventListener('mouseup', handleMouseUp);
    document.removeEventListener('touchmove', handleMouseMove); // For touch
    document.removeEventListener('touchend', handleMouseUp); // For touch
    if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
    }
  }, [handleMouseMove, handleMouseUp]);

  const handleMouseDown = useCallback((e: React.MouseEvent | React.TouchEvent) => {
    if (duration === 0 || !videoLoaded) return;
    setIsDragging(true);
    e.preventDefault();

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
    document.addEventListener('touchmove', handleMouseMove);
    document.addEventListener('touchend', handleMouseUp);
  }, [duration, videoLoaded, handleMouseMove, handleMouseUp]);

  useEffect(() => {
    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
      document.removeEventListener('touchmove', handleMouseMove);
      document.removeEventListener('touchend', handleMouseUp);
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, [handleMouseMove, handleMouseUp]);

  if (duration === 0 || !videoLoaded) return null;

  return (
    <div
      ref={playheadRef}
      className={`absolute top-0 bottom-0 z-30 select-none group ${isDragging ? 'cursor-grabbing' : 'cursor-grab'}`}
      style={{ left: `${leftPx}px` }}
      onMouseDown={handleMouseDown}
      onTouchStart={handleMouseDown}
    >
      <div className="w-1 h-full bg-blue-500 absolute left-1/2 -translate-x-1/2 rounded-full shadow-lg"></div>
      <svg
        className="absolute -top-3 left-1/2 -translate-x-1/2"
        width="16"
        height="12"
        viewBox="0 0 16 12"
        fill="#3B82F6"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M8 0L0 12H16L8 0Z" />
      </svg>
      <div className={`absolute top-1/2 left-1/2 -translate-x-1/2 bg-gray-900 text-gray-200 text-xs px-2 py-1 rounded-md whitespace-nowrap -mt-10 pointer-events-none transition-opacity duration-150 ${isDragging ? 'opacity-100' : 'opacity-0 group-hover:opacity-100'}`}>
        {formatTime(currentTime)}
      </div>
    </div>
  );
});