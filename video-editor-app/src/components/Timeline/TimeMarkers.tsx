// src/components/Timeline/TimeMarkers.tsx
import React from 'react';
import { calculatePosition } from './TimelineUtils';
import { formatTime } from '../../utils/formatTime';

interface TimeMarkersProps {
  duration: number;
  timelineWidthPx: number;
  zoomLevel: number; // Added zoom level
}

export const TimeMarkers: React.FC<TimeMarkersProps> = React.memo(({ duration, timelineWidthPx, zoomLevel }) => {
  const markers = [];
  const totalDisplayWidth = timelineWidthPx; // This is the actual display width

  // Dynamic interval logic for markers based on zoom and actual width
  let intervalSeconds = 1; // Smallest interval
  if (totalDisplayWidth / duration < 10) { // If less than 10px per second, adjust
      intervalSeconds = 5;
  }
  if (totalDisplayWidth / duration < 3) { // If less than 3px per second, adjust further
      intervalSeconds = 10;
  }
  if (totalDisplayWidth / duration < 1) { // If less than 1px per second, adjust
      intervalSeconds = 30;
  }
  if (totalDisplayWidth / duration < 0.5) { // For very long videos
      intervalSeconds = 60;
  }

  // Define major/minor tick logic
  const majorTickFactor = (intervalSeconds === 1 || intervalSeconds === 5) ? 5 : 2; // Every 5s or 10s for smaller intervals

  for (let i = 0; i <= duration; i += intervalSeconds) {
    const leftPx = calculatePosition(i, duration, totalDisplayWidth);

    const isMajorTick = (i % (intervalSeconds * majorTickFactor)) === 0 || i === 0;

    markers.push(
      <div
        key={`marker-${i}`}
        className="absolute h-full z-0 pointer-events-none"
        style={{ left: `${leftPx}px` }}
      >
        <div className={`absolute bottom-0 w-[1px] ${isMajorTick ? 'h-4 bg-gray-400' : 'h-2 bg-gray-500'}`}></div>
        {isMajorTick && (
          <span className="absolute -bottom-6 left-1/2 -translate-x-1/2 text-xs text-gray-400 whitespace-nowrap">
            {formatTime(i)}
          </span>
        )}
      </div>
    );
  }

  return <>{markers}</>;
});