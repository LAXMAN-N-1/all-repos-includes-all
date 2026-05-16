import React, { useState, useRef, useEffect, useCallback, memo } from 'react';
import { PlayCircle, Lightbulb, Upload } from 'lucide-react';

// =================================================================
// 1. UTILITY FUNCTIONS
// =================================================================
const formatTime = (timeInSeconds) => {
  if (isNaN(timeInSeconds) || timeInSeconds === 0) {
    return '00:00';
  }
  const minutes = Math.floor(timeInSeconds / 60);
  const seconds = Math.floor(timeInSeconds % 60);
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
};

// =================================================================
// 2. MOCK DATA & TYPES
// We will use this mock transcript to generate dynamic key moments,
// as the app cannot automatically transcribe a video.
// =================================================================
const SAMPLE_VIDEO_URL = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4";
const MOCK_TRANSCRIPT = `
In this video, we're going to dive deep into the world of quantum computing. We'll start by defining what a qubit is and how it differs from a classical bit. Unlike a bit, which can be either 0 or 1, a qubit can be in a superposition of both states simultaneously. This property is what gives quantum computers their incredible power.

Next, we'll discuss the concept of entanglement. When two qubits are entangled, the state of one is directly linked to the state of the other, no matter how far apart they are. This "spooky action at a distance," as Einstein called it, is a fundamental principle of quantum mechanics.

Then, we'll move on to a practical example: Shor's algorithm. This is a quantum algorithm for integer factorization, which has significant implications for modern cryptography. While classical computers would take billions of years to factor very large numbers, a quantum computer using Shor's algorithm could do it in a matter of hours or even minutes. We'll walk through a simplified explanation of how it works.

Finally, we'll wrap up by discussing the current state of the industry. We'll look at the major players, the challenges of building and maintaining stable quantum systems, and what the future holds for this transformative technology. We'll touch on the potential applications in fields like medicine, materials science, and AI.
`;

const mockVideoSegments = [
  { id: 's1', start: 5, end: 10, type: 'silent' },
  { id: 's2', start: 20, end: 30, type: 'highlight' },
  { id: 's3', start: 50, end: 55, type: 'silent' },
  { id: 's4', start: 60, end: 63, type: 'highlight' },
];

// =================================================================
// 3. CUSTOM HOOKS
// =================================================================
const useVideoPlayer = () => {
  const videoRef = useRef(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [videoLoaded, setVideoLoaded] = useState(false);
  const [currentVideoSrc, setVideoSource] = useState(null);

  useEffect(() => {
    const videoElement = videoRef.current;
    if (!videoElement) return;

    const handleTimeUpdate = () => setCurrentTime(videoElement.currentTime);
    const handleLoadedMetadata = () => {
      setDuration(videoElement.duration);
      setVideoLoaded(true);
    };
    const handlePlay = () => setIsPlaying(true);
    const handlePause = () => setIsPlaying(false);
    const handleEnded = () => setIsPlaying(false);

    videoElement.addEventListener('timeupdate', handleTimeUpdate);
    videoElement.addEventListener('loadedmetadata', handleLoadedMetadata);
    videoElement.addEventListener('play', handlePlay);
    videoElement.addEventListener('pause', handlePause);
    videoElement.addEventListener('ended', handleEnded);

    return () => {
      videoElement.removeEventListener('timeupdate', handleTimeUpdate);
      videoElement.removeEventListener('loadedmetadata', handleLoadedMetadata);
      videoElement.removeEventListener('play', handlePlay);
      videoElement.removeEventListener('pause', handlePause);
      videoElement.removeEventListener('ended', handleEnded);

      if (currentVideoSrc && currentVideoSrc.startsWith('blob:')) {
        URL.revokeObjectURL(currentVideoSrc);
      }
    };
  }, [currentVideoSrc]);

  const togglePlay = useCallback(() => {
    if (videoRef.current) {
      if (isPlaying) {
        videoRef.current.pause();
      } else {
        videoRef.current.play();
      }
    }
  }, [isPlaying]);

  const seek = useCallback((time) => {
    if (videoRef.current) {
      videoRef.current.currentTime = time;
    }
  }, []);

  return { videoRef, isPlaying, currentTime, duration, videoLoaded, togglePlay, seek, currentVideoSrc, setVideoSource };
};

// =================================================================
// 4. UI COMPONENTS
// =================================================================
const Button = memo(({ onClick, children, className, variant = 'primary', disabled = false, ...props }) => {
  const baseStyle = 'inline-flex items-center justify-center rounded-full font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 transform active:scale-95';

  const variants = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-white/10 text-gray-200 hover:bg-white/20 focus:ring-blue-500 backdrop-blur-sm',
    ghost: 'bg-transparent text-blue-400 hover:text-blue-200 focus:ring-blue-500',
    purple: 'bg-gradient-to-r from-purple-500 to-blue-500 hover:from-purple-600 hover:to-blue-600 text-white',
  };

  const disabledStyle = disabled ? 'opacity-50 cursor-not-allowed' : '';
  const finalClassName = `${baseStyle} ${variants[variant]} ${disabledStyle} ${className || ''}`;

  return (
    <button className={finalClassName} onClick={onClick} disabled={disabled} {...props}>
      {children}
    </button>
  );
});

const PlayPauseButton = memo(({ isPlaying, onClick, disabled = false, className = '' }) => (
  <Button onClick={onClick} disabled={disabled} className={`w-16 h-16 ${className} p-0`}>
    {isPlaying ? (
      <svg className="h-8 w-8 text-white" fill="currentColor" viewBox="0 0 20 20">
        <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clipRule="evenodd" />
      </svg>
    ) : (
      <svg className="h-8 w-8 text-white" fill="currentColor" viewBox="0 0 20 20">
        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4.053a1 1 0 001.555.832l3.044-2.027a1 1 0 000-1.664l-3.044-2.027z" clipRule="evenodd" />
      </svg>
    )}
  </Button>
));

const FileUpload = memo(({ onFileSelect, onUseSample }) => {
  const [isDragOver, setIsDragOver] = useState(false);

  const handleDragOver = useCallback((event) => {
    event.preventDefault();
    setIsDragOver(true);
  }, []);

  const handleDragLeave = useCallback(() => {
    setIsDragOver(false);
  }, []);

  const handleDrop = useCallback((event) => {
    event.preventDefault();
    setIsDragOver(false);
    if (event.dataTransfer.files && event.dataTransfer.files.length > 0) {
      onFileSelect(event.dataTransfer.files[0]);
    }
  }, [onFileSelect]);

  const handleFileChange = useCallback((event) => {
    if (event.target.files && event.target.files.length > 0) {
      onFileSelect(event.target.files[0]);
    }
  }, [onFileSelect]);

  return (
    <div className="flex flex-col gap-8">
      <div
        className={`flex flex-col items-center justify-center p-12 border-2 border-dashed rounded-3xl transition-all duration-200 ${isDragOver ? 'border-blue-500 bg-white/10' : 'border-white/20 bg-white/5'}`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
      >
        <svg xmlns="http://www.w3.org/2000/svg" className="h-16 w-16 text-white/50 mb-4 animate-bounce-slow" viewBox="0 0 20 20" fill="currentColor">
          <path d="M16 16v-1a4 4 0 00-4-4H8a4 4 0 00-4 4v1m4-11V4a3 3 0 016 0v2m-6 0h6m-5 4H9m7-4H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2z" />
        </svg>
        <p className="text-white font-medium text-lg mb-2">Drag and drop your video file</p>
        <p className="text-white/60 text-sm mb-4">or</p>
        <label className="cursor-pointer">
          <span className="bg-blue-600 text-white py-3 px-8 rounded-full font-semibold shadow-lg hover:bg-blue-700 transition-colors duration-200 transform hover:scale-105">
            Browse Files
          </span>
          <input type="file" onChange={handleFileChange} className="hidden" accept="video/*" />
        </label>
      </div>

      <div className="relative flex items-center">
        <div className="flex-grow border-t border-white/10"></div>
        <span className="flex-shrink mx-4 text-white/50 font-medium text-sm">OR</span>
        <div className="flex-grow border-t border-white/10"></div>
      </div>

      <Button onClick={() => onUseSample(SAMPLE_VIDEO_URL)} variant="purple" className="w-full py-4 text-xl">
        Use Sample Video
      </Button>
    </div>
  );
});

const VideoPlayer = memo(({ videoControls }) => {
  const { videoRef, isPlaying, currentTime, duration, togglePlay, seek, videoLoaded, currentVideoSrc } = videoControls;

  const handleSeekChange = useCallback((event) => {
    const time = parseFloat(event.target.value);
    seek(time);
  }, [seek]);

  const currentFormattedTime = formatTime(currentTime);
  const totalFormattedDuration = formatTime(duration);

  return (
    <div className="flex flex-col items-center bg-white/5 border border-white/10 backdrop-blur-md rounded-3xl p-6 shadow-2xl-glassmorphic w-full h-full transform transition-transform duration-300 hover:scale-[1.01]">
      <div className="relative w-full aspect-video bg-black flex items-center justify-center rounded-2xl overflow-hidden shadow-xl">
        {currentVideoSrc ? (
          <video
            ref={videoRef}
            src={currentVideoSrc}
            className="w-full h-full object-contain"
            onContextMenu={(e) => e.preventDefault()}
            preload="metadata"
          />
        ) : (
          <p className="text-white/40 text-xl font-light">No video loaded. Upload or use sample.</p>
        )}

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

      <div className="flex items-center justify-between w-full mt-6 gap-6 px-2">
        <PlayPauseButton
          isPlaying={isPlaying}
          onClick={togglePlay}
          disabled={!videoLoaded}
          className="hidden sm:flex"
        />

        <span className="text-white/70 font-mono text-sm min-w-[50px] text-center">{currentFormattedTime}</span>

        <input
          type="range"
          min="0"
          max={duration}
          value={currentTime}
          step="0.01"
          onChange={handleSeekChange}
          className="flex-grow h-2 bg-white/20 rounded-full appearance-none cursor-pointer
            [&::-webkit-slider-thumb]:w-5 [&::-webkit-slider-thumb]:h-5 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-blue-400 [&::-webkit-slider-thumb]:shadow-glow-blue [&::-webkit-slider-thumb]:-mt-[5px] [&::-webkit-slider-thumb]:relative [&::-webkit-slider-thumb]:z-10 [&::-webkit-slider-thumb]:transition-all [&::-webkit-slider-thumb]:duration-200
            [&::-moz-range-thumb]:w-5 [&::-moz-range-thumb]:h-5 [&::-moz-range-thumb]:rounded-full [&::-moz-range-thumb]:bg-blue-400 [&::-moz-range-thumb]:border-none [&::-moz-range-thumb]:shadow-glow-blue [&::-moz-range-thumb]:transition-all [&::-moz-range-thumb]:duration-200
            "
          disabled={!videoLoaded || duration === 0}
        />

        <span className="text-white/70 font-mono text-sm min-w-[50px] text-center">{totalFormattedDuration}</span>
      </div>
    </div>
  );
});

const calculatePosition = (time, totalDuration, timelineWidthPx) => {
    if (totalDuration === 0 || timelineWidthPx === 0) return 0;
    return (time / totalDuration) * timelineWidthPx;
};

const calculateWidth = (durationSeconds, totalDuration, timelineWidthPx) => {
    if (totalDuration === 0 || timelineWidthPx === 0) return 0;
    return (durationSeconds / totalDuration) * timelineWidthPx;
};

const Playhead = memo(({ currentTime, duration, timelineWidthPx, onSeek, videoLoaded }) => {
  const playheadRef = useRef(null);
  const [isDragging, setIsDragging] = useState(false);
  const animationFrameRef = useRef(null);

  const leftPx = calculatePosition(currentTime, duration, timelineWidthPx);

  const handleMouseMove = useCallback((e) => {
    if (!isDragging || !playheadRef.current || duration === 0 || !videoLoaded) return;

    if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
    }

    animationFrameRef.current = requestAnimationFrame(() => {
        const timelineRect = playheadRef.current.parentElement.getBoundingClientRect();
        if (!timelineRect) return;

        const mouseX = e.clientX;
        const relativeX = mouseX - timelineRect.left + playheadRef.current.parentElement.parentElement.scrollLeft;

        const clampedX = Math.max(0, Math.min(relativeX, timelineWidthPx));

        const newTime = (clampedX / timelineWidthPx) * duration;
        onSeek(newTime);
    });
  }, [isDragging, duration, timelineWidthPx, onSeek, videoLoaded]);

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
    document.removeEventListener('mousemove', handleMouseMove);
    document.removeEventListener('mouseup', handleMouseUp);
    document.removeEventListener('touchmove', handleMouseMove);
    document.removeEventListener('touchend', handleMouseUp);
    if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
    }
  }, [handleMouseMove]);

  const handleMouseDown = useCallback((e) => {
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
      <div className="w-1 h-full bg-blue-500 absolute left-1/2 -translate-x-1/2 rounded-full shadow-glow-blue transition-all duration-200"></div>
      <svg
        className="absolute -top-3 left-1/2 -translate-x-1/2 drop-shadow-lg"
        width="16"
        height="12"
        viewBox="0 0 16 12"
        fill="#3B82F6"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M8 0L0 12H16L8 0Z" />
      </svg>
      <div className={`absolute top-1/2 left-1/2 -translate-x-1/2 bg-white/10 border border-white/20 backdrop-blur-lg text-white text-xs px-3 py-1.5 rounded-md whitespace-nowrap -mt-10 pointer-events-none transition-all duration-200 ${isDragging ? 'opacity-100 scale-100' : 'opacity-0 scale-95 group-hover:opacity-100 group-hover:scale-100'}`}>
        {formatTime(currentTime)}
      </div>
    </div>
  );
});

const TimeMarkers = memo(({ duration, timelineWidthPx, zoomLevel }) => {
  const markers = [];
  const totalDisplayWidth = timelineWidthPx;

  let intervalSeconds = 1;
  if (totalDisplayWidth / duration < 10) {
      intervalSeconds = 5;
  }
  if (totalDisplayWidth / duration < 3) {
      intervalSeconds = 10;
  }
  if (totalDisplayWidth / duration < 1) {
      intervalSeconds = 30;
  }
  if (totalDisplayWidth / duration < 0.5) {
      intervalSeconds = 60;
  }

  const majorTickFactor = (intervalSeconds === 1 || intervalSeconds === 5) ? 5 : 2;

  for (let i = 0; i <= duration; i += intervalSeconds) {
    const leftPx = calculatePosition(i, duration, totalDisplayWidth);

    const isMajorTick = (i % (intervalSeconds * majorTickFactor)) === 0 || i === 0;

    markers.push(
      <div
        key={`marker-${i}`}
        className="absolute h-full z-0 pointer-events-none"
        style={{ left: `${leftPx}px` }}
      >
        <div className={`absolute bottom-0 w-[1px] transition-all duration-200 ${isMajorTick ? 'h-6 bg-white/40' : 'h-3 bg-white/20'}`}></div>
        {isMajorTick && (
          <span className="absolute -bottom-7 left-1/2 -translate-x-1/2 text-xs text-white/50 whitespace-nowrap font-mono">
            {formatTime(i)}
          </span>
        )}
      </div>
    );
  }
  return <>{markers}</>;
});

const SegmentDisplay = memo(({ segments, duration, timelineWidthPx }) => {
  return (
    <>
      {segments.map((segment) => {
        const left = calculatePosition(segment.start, duration, timelineWidthPx);
        const width = calculateWidth(segment.end - segment.start, duration, timelineWidthPx);

        const colorClass = segment.type === 'silent' ? 'bg-red-400' : 'bg-green-400';
        const displayWidth = Math.max(width, 2);

        return (
          <div
            key={segment.id}
            className={`absolute bottom-0 h-2/3 ${colorClass} opacity-30 rounded-sm z-10 transition-all duration-100 ease-in-out`}
            style={{ left: `${left}px`, width: `${displayWidth}px` }}
            title={`${segment.type === 'silent' ? 'Silent' : 'Highlighted'} segment: ${segment.start}s - ${segment.end}s`}
          ></div>
        );
      })}
    </>
  );
});

const Timeline = memo(({ currentTime, duration, onSeek, segments, videoLoaded }) => {
  const timelineContainerRef = useRef(null);
  const [timelineDisplayWidth, setTimelineDisplayWidth] = useState(0);
  const [zoomLevel, setZoomLevel] = useState(1);
  const pixelsPerSecond = 50;
  const contentWidthRef = useRef(0);
  const scrollRef = useRef(null);

  useEffect(() => {
    if (!timelineContainerRef.current) return;

    const resizeObserver = new ResizeObserver(entries => {
      for (let entry of entries) {
        setTimelineDisplayWidth(entry.contentRect.width);
      }
    });

    resizeObserver.observe(timelineContainerRef.current);
    return () => {
      if (timelineContainerRef.current) {
        resizeObserver.unobserve(timelineContainerRef.current);
      }
    };
  }, []);

  const handleTimelineClick = useCallback((e) => {
    if (duration === 0 || !scrollRef.current || !videoLoaded) return;
    const timelineRect = scrollRef.current.getBoundingClientRect();
    const clickX = e.clientX - timelineRect.left + scrollRef.current.scrollLeft;
    const newTime = (clickX / contentWidthRef.current) * duration;
    onSeek(newTime);
  }, [duration, onSeek, videoLoaded]);

  const handleZoomIn = useCallback(() => {
    setZoomLevel(prev => Math.min(5, prev + 0.5));
  }, []);

  const handleZoomOut = useCallback(() => {
    setZoomLevel(prev => Math.max(0.5, prev - 0.5));
  }, []);

  const totalTimelineContentWidth = duration * pixelsPerSecond * zoomLevel;
  contentWidthRef.current = Math.max(totalTimelineContentWidth, timelineDisplayWidth);

  useEffect(() => {
      if (scrollRef.current && contentWidthRef.current > timelineDisplayWidth) {
          const scrollPosition = (currentTime / duration) * contentWidthRef.current - (timelineDisplayWidth / 2);
          scrollRef.current.scrollLeft = Math.max(0, scrollPosition);
      }
  }, [currentTime, duration, timelineDisplayWidth, contentWidthRef.current]);

  if (duration === 0 || !videoLoaded) {
    return (
      <div className="w-full h-32 bg-white/5 border border-white/10 backdrop-blur-md rounded-3xl flex items-center justify-center text-white/50 text-xl font-light">
        Load a video to see the timeline.
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex justify-between items-center px-4">
        <h2 className="text-2xl font-bold text-white/90 font-display">Timeline</h2>
        <div className="flex gap-2">
          <Button onClick={handleZoomOut} variant="secondary" className="px-4 py-2">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clipRule="evenodd" />
            </svg>
          </Button>
          <Button onClick={handleZoomIn} variant="secondary" className="px-4 py-2">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clipRule="evenodd" />
            </svg>
          </Button>
        </div>
      </div>

      <div
        ref={timelineContainerRef}
        className="relative w-full h-32 bg-white/5 border border-white/10 backdrop-blur-md rounded-3xl overflow-x-auto overflow-y-hidden shadow-2xl-glassmorphic custom-scrollbar"
      >
        <div
          ref={scrollRef}
          className="h-full relative overflow-hidden"
        >
          <div
            className="h-full relative flex flex-col justify-end pb-8"
            style={{ width: `${contentWidthRef.current}px` }}
            onClick={handleTimelineClick}
          >
            <div className="absolute inset-0 bg-white/5 rounded-3xl"></div>
            <TimeMarkers duration={duration} timelineWidthPx={contentWidthRef.current} zoomLevel={zoomLevel} />
            <SegmentDisplay segments={mockVideoSegments} duration={duration} timelineWidthPx={contentWidthRef.current} />
            <Playhead
              currentTime={currentTime}
              duration={duration}
              timelineWidthPx={contentWidthRef.current}
              onSeek={onSeek}
              videoLoaded={videoLoaded}
            />
          </div>
        </div>
      </div>
    </div>
  );
});

// A new function to generate consistent key moments based on video duration
const generateConsistentKeyMoments = (duration) => {
  if (duration === 0) return [];

  const numMoments = 5;
  const moments = [];
  const interval = duration / (numMoments + 1); // +1 to avoid the last moment being at the very end

  for (let i = 1; i <= numMoments; i++) {
    const timestamp = Math.round(interval * i);
    moments.push({
      id: `moment-${i}`,
      title: `Key Moment ${i}`,
      timestamp: timestamp,
    });
  }
  
  return moments;
};

const KeyMomentsList = memo(({ keyMoments, onSeek, videoLoaded, onGenerate }) => {
  const handleKeyMomentClick = useCallback((timestamp) => {
    if (videoLoaded) {
      onSeek(timestamp);
    }
  }, [onSeek, videoLoaded]);

  return (
    <div className="w-full bg-white/5 border border-white/10 backdrop-blur-md rounded-3xl p-6 shadow-2xl-glassmorphic overflow-y-auto max-h-96 custom-scrollbar transform transition-transform duration-300 hover:scale-[1.01]">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-white/90 font-display">Key Moments</h2>
        <Button
          onClick={onGenerate}
          variant="purple"
          className="px-6 py-2 text-sm disabled:opacity-50"
          disabled={!videoLoaded}
        >
          <Lightbulb className="w-4 h-4 mr-2" />
          Generate
        </Button>
      </div>

      {keyMoments.length === 0 ? (
        <div className="text-center text-white/40 font-light">
          {videoLoaded ? "Click 'Generate' to create a consistent set of key moments." : "Load a video to see key moments."}
        </div>
      ) : (
        <ul className="space-y-4">
          {keyMoments.map((moment) => (
            <li
              key={moment.id}
              className="flex items-center justify-between p-4 bg-white/5 rounded-2xl shadow-sm transition-all duration-200 hover:bg-white/10 transform hover:-translate-y-1 hover:shadow-lg-glow"
            >
              <span className="text-white/80 text-base font-medium truncate">{moment.title}</span>
              <Button
                onClick={() => handleKeyMomentClick(moment.timestamp)}
                variant="ghost"
                className="ml-4 flex-shrink-0 !text-sm text-blue-400 hover:text-blue-200 transform hover:scale-105"
                disabled={!videoLoaded}
              >
                <PlayCircle className="h-4 w-4 mr-1" />
                {formatTime(moment.timestamp)}
              </Button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
});

// =================================================================
// 5. MAIN APP COMPONENT
// =================================================================
function App() {
  const videoControls = useVideoPlayer();
  const { setVideoSource, videoLoaded, videoRef, duration, seek, isPlaying } = videoControls;
  const [showFileUpload, setShowFileUpload] = useState(true);
  const [keyMoments, setKeyMoments] = useState([]);

  // Removed the useEffect to auto-generate moments on load.
  // Now, the user must click the 'Generate' button.

  const handleNewUpload = useCallback(() => {
    setVideoSource(null);
    setShowFileUpload(true);
    setKeyMoments([]); // Clear key moments on new upload
  }, [setVideoSource]);

  const handleUseSample = useCallback((url) => {
    setVideoSource(url);
    setShowFileUpload(false);
  }, [setVideoSource]);

  const handleFileSelect = useCallback((file) => {
    const url = URL.createObjectURL(file);
    setVideoSource(url);
    setShowFileUpload(false);
  }, [setVideoSource]);

  useEffect(() => {
    const handleKeyDown = (event) => {
      if (event.key === ' ' && event.target === document.body && videoRef.current) {
        event.preventDefault();
        if (isPlaying) {
          videoRef.current.pause();
        } else {
          videoRef.current.play();
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [videoRef, isPlaying]);

  return (
    <div className="min-h-screen relative overflow-hidden text-white font-sans bg-gray-950">
      <div className="background-effects">
        <div className="blob-1"></div>
        <div className="blob-2"></div>
        <div className="blob-3"></div>
        <div className="blob-4"></div>
      </div>

      <div className="relative z-10 p-4 sm:p-10 flex flex-col items-center">
        <header className="mb-12 w-full max-w-7xl text-center flex flex-col items-center">
          <div className="flex items-center justify-center w-full relative">
            <h1 className="text-4xl sm:text-6xl font-extrabold text-white font-display mb-2 drop-shadow-lg">
              Loopdesk Video Analytics
            </h1>
            {!showFileUpload && (
              <div className="absolute right-0 top-1/2 -translate-y-1/2">
                <Button onClick={handleNewUpload} variant="secondary" className="hidden sm:inline-flex px-6 py-3 text-base">
                  <Upload className="h-5 w-5 mr-2" />
                  New Upload
                </Button>
                <Button onClick={handleNewUpload} variant="secondary" className="sm:hidden px-3 py-3">
                  <Upload className="h-5 w-5" />
                </Button>
              </div>
            )}
          </div>
          <p className="mt-2 text-lg sm:text-xl text-white/70 font-light max-w-2xl mx-auto">
            Visually analyze key moments, highlights, and silent segments in your videos with a powerful, modern UI.
          </p>
        </header>

        {showFileUpload && (
          <div className="bg-white/5 border border-white/10 backdrop-blur-md p-8 sm:p-12 rounded-3xl shadow-2xl-glassmorphic text-center w-full max-w-xl animate-fade-in-up">
            <p className="text-2xl sm:text-3xl font-semibold mb-8 text-white font-display drop-shadow-md">Get Started</p>
            <FileUpload onFileSelect={handleFileSelect} onUseSample={handleUseSample} />
          </div>
        )}

        {!showFileUpload && (
          <main className="w-full max-w-7xl grid grid-cols-1 lg:grid-cols-3 gap-10 transition-opacity duration-500 animate-fade-in-up">
            <div className="lg:col-span-2 flex flex-col gap-10">
              <VideoPlayer videoControls={videoControls} />
              <Timeline
                currentTime={videoControls.currentTime}
                duration={duration}
                onSeek={seek}
                segments={mockVideoSegments}
                videoLoaded={videoLoaded}
              />
            </div>
            <div className="lg:col-span-1">
              <KeyMomentsList
                keyMoments={keyMoments}
                onSeek={seek}
                videoLoaded={videoLoaded}
                onGenerate={() => setKeyMoments(generateConsistentKeyMoments(duration))}
              />
            </div>
          </main>
        )}
      </div>

      <style>
        {`
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap');
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

        .font-sans { font-family: 'Inter', sans-serif; }
        .font-display { font-family: 'Poppins', sans-serif; }

        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .animate-fade-in-up {
          animation: fadeInUp 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        .animate-fade-in {
          animation: fadeIn 0.5s ease-out;
        }

        .custom-scrollbar::-webkit-scrollbar {
          height: 8px;
          width: 8px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: rgba(255, 255, 255, 0.05);
          border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background-color: rgba(255, 255, 255, 0.2);
          border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background-color: rgba(255, 255, 255, 0.3);
        }

        .shadow-2xl-glassmorphic {
          box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06), inset 0 1px 0 rgba(255, 255, 255, 0.1);
        }
        .shadow-lg-glow {
          box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05), 0 0 15px rgba(59, 130, 246, 0.5);
        }
        .shadow-glow-blue {
          box-shadow: 0 0 8px 1px rgba(59, 130, 246, 0.6);
        }

        .background-effects {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          z-index: 0;
          overflow: hidden;
        }
        .blob-1, .blob-2, .blob-3, .blob-4 {
          position: absolute;
          border-radius: 50%;
          filter: blur(100px);
          opacity: 0.3;
          animation: float 20s ease-in-out infinite;
        }
        .blob-1 { top: 10%; left: 15%; width: 400px; height: 400px; background: #6366F1; animation-delay: -2s; }
        .blob-2 { bottom: 20%; right: 10%; width: 500px; height: 500px; background: #A855F7; animation-delay: -4s; }
        .blob-3 { top: 50%; right: 30%; width: 350px; height: 350px; background: #3B82F6; animation-delay: -6s; }
        .blob-4 { bottom: 5%; left: 40%; width: 450px; height: 450px; background: #EC4899; animation-delay: -8s; }

        @keyframes float {
          0%, 100% { transform: translateY(0) rotate(0deg); }
          25% { transform: translateY(-30px) rotate(5deg); }
          50% { transform: translateY(0) rotate(0deg); }
          75% { transform: translateY(30px) rotate(-5deg); }
        }
        `}
      </style>
    </div>
  );
}

export default App;