// src/components/Timeline/index.tsx
import React, { useRef, useState, useEffect, useCallback } from 'react';
import { Playhead } from './Playhead';
import { TimeMarkers } from './TimeMarkers';
import { SegmentDisplay } from './SegmentDisplay';
import { VideoSegment } from '../Shared.types';
import { calculatePosition } from './TimelineUtils';
import { Button } from '../UI/Button'; // Import Button component

interface TimelineProps {
  currentTime: number;
  duration: number;
  onSeek: (time: number) => void;
  segments: VideoSegment[];
  videoLoaded: boolean;
}

export const Timeline: React.FC<TimelineProps> = React.memo(({ currentTime, duration, onSeek, segments, videoLoaded }) => {
  const timelineContainerRef = useRef<HTMLDivElement>(null); // Reference to the scrollable container
  const timelineContentRef = useRef<HTMLDivElement>(null); // Reference to the content *inside* the scrollable container
  const [timelineDisplayWidth, setTimelineDisplayWidth] = useState(0); // The visible width of the timeline
  const [zoomLevel, setZoomLevel] = useState(1); // 1 = 1x zoom, 2 = 2x zoom, etc.
  const pixelsPerSecond = 50; // Base pixels per second at 1x zoom

  // Update timeline width on resize
  useEffect(() => {
    if (!timelineContainerRef.current) return;

    const resizeObserver = new ResizeObserver(entries => {
      for (let entry of entries) {
        setTimelineDisplayWidth(entry.contentRect.width);
      }
    });

    resizeObserver.observe(timelineContainerRef.current);

    setTimelineDisplayWidth(timelineContainerRef.current.clientWidth);

    return () => {
      if (timelineContainerRef.current) {
        resizeObserver.unobserve(timelineContainerRef.current);
      }
    };
  }, []);

  const handleTimelineClick = useCallback((e: React.MouseEvent<HTMLDivElement>) => {
    if (duration === 0 || !timelineContentRef.current || !videoLoaded) return;

    const timelineRect = timelineContentRef.current.getBoundingClientRect(); // Get rect of the actual content area
    const clickX = e.clientX - timelineRect.left;
    const newTime = (clickX / (duration * pixelsPerSecond * zoomLevel)) * duration; // Calculate based on full content width
    onSeek(newTime);
  }, [duration, onSeek, videoLoaded, pixelsPerSecond, zoomLevel]);

  const handleZoomIn = useCallback(() => {
    setZoomLevel(prev => Math.min(5, prev + 0.5)); // Zoom in by 0.5x, max 5x
  }, []);

  const handleZoomOut = useCallback(() => {
    setZoomLevel(prev => Math.max(0.5, prev - 0.5)); // Zoom out by 0.5x, min 0.5x
  }, []);

  // Calculate the total width of the *content* inside the timeline container
  const totalTimelineContentWidth = duration * pixelsPerSecond * zoomLevel;
  // Ensure the timeline content is at least the display width, so it doesn't shrink smaller than container
  const actualTimelineContentWidth = Math.max(totalTimelineContentWidth, timelineDisplayWidth);


  if (duration === 0 || !videoLoaded) {
    return (
      <div className="w-full h-24 bg-gray-800 rounded-xl flex items-center justify-center text-gray-400 text-lg shadow-inner">
        Load a video to see the timeline.
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex justify-between items-center px-2">
        <h2 className="text-2xl font-bold text-gray-200">Video Timeline</h2>
        <div className="flex gap-2">
          <Button onClick={handleZoomOut} variant="secondary" className="px-3 py-1.5 text-lg">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clipRule="evenodd" />
            </svg>
          </Button>
          <Button onClick={handleZoomIn} variant="secondary" className="px-3 py-1.5 text-lg">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clipRule="evenodd" />
            </svg>
          </Button>
        </div>
      </div>

      <div
        ref={timelineContainerRef}
        className="relative w-full h-24 bg-gray-800 rounded-xl overflow-x-auto overflow-y-hidden shadow-inner custom-scrollbar"
      >
        <div
          ref={timelineContentRef}
          className="relative h-full flex flex-col justify-end pb-7"
          style={{ width: `${actualTimelineContentWidth}px` }}
          onClick={handleTimelineClick}
        >
          {/* Background for timeline track */}
          <div className="absolute inset-0 bg-gray-900 rounded-xl"></div>

          {/* Markers */}
          <TimeMarkers duration={duration} timelineWidthPx={actualTimelineContentWidth} zoomLevel={zoomLevel} />

          {/* Segments (silent/highlighted) */}
          <SegmentDisplay segments={segments} duration={duration} timelineWidthPx={actualTimelineContentWidth} />

          {/* Playhead - positioned on top */}
          <Playhead
            currentTime={currentTime}
            duration={duration}
            timelineWidthPx={actualTimelineContentWidth}
            onSeek={onSeek}
            videoLoaded={videoLoaded}
          />
        </div>
      </div>

      <div className="text-right text-lg text-gray-300 font-mono pr-2">
        {formatTime(currentTime)} / {formatTime(duration)}
      </div>
      {/* Custom scrollbar styling */}
      <style jsx>{`
        .custom-scrollbar::-webkit-scrollbar {
          height: 8px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: #2d3748; /* gray-800 */
          border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background-color: #4a5568; /* gray-600 */
          border-radius: 4px;
          border: 2px solid #2d3748;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background-color: #646b77; /* gray-500 hover */
        }
      `}</style>
    </div>
  );
});