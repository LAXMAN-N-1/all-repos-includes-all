// src/components/Timeline/SegmentDisplay.tsx
import React from 'react';
import { VideoSegment } from '../Shared.types';
import { calculatePosition, calculateWidth } from './TimelineUtils';

interface SegmentDisplayProps {
  segments: VideoSegment[];
  duration: number;
  timelineWidthPx: number;
}

export const SegmentDisplay: React.FC<SegmentDisplayProps> = React.memo(({ segments, duration, timelineWidthPx }) => {
  return (
    <>
      {segments.map(segment => {
        const left = calculatePosition(segment.start, duration, timelineWidthPx);
        const width = calculateWidth(segment.end - segment.start, duration, timelineWidthPx);

        const colorClass = segment.type === 'silent' ? 'bg-red-700' : 'bg-green-700';
        const displayWidth = Math.max(width, 2); // Ensure minimum width for visibility

        return (
          <div
            key={segment.id}
            className={`absolute top-0 h-full ${colorClass} opacity-40 rounded-sm z-10 transition-all duration-100 ease-in-out`}
            style={{ left: `${left}px`, width: `${displayWidth}px` }}
            title={`${segment.type === 'silent' ? 'Silent' : 'Highlighted'} segment: ${segment.start}s - ${segment.end}s`}
          ></div>
        );
      })}
    </>
  );
});