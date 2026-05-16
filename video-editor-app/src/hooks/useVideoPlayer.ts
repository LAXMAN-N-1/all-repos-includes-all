// src/hooks/useVideoPlayer.ts
import { useState, useRef, useEffect, useCallback } from 'react';

interface UseVideoPlayerReturn {
  videoRef: React.RefObject<HTMLVideoElement>;
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  play: () => void;
  pause: () => void;
  togglePlay: () => void;
  seek: (time: number) => void;
  setVideoSource: (src: string | null) => void;
  videoLoaded: boolean;
  currentVideoSrc: string | null; // Added to pass down the current source
}

export const useVideoPlayer = (): UseVideoPlayerReturn => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [currentVideoSrc, setCurrentVideoSrc] = useState<string | null>(null);
  const [videoLoaded, setVideoLoaded] = useState(false);

  const play = useCallback(() => {
    if (videoRef.current && videoLoaded) {
      videoRef.current.play().catch(e => console.error("Error playing video:", e));
      setIsPlaying(true);
    }
  }, [videoLoaded]);

  const pause = useCallback(() => {
    if (videoRef.current) {
      videoRef.current.pause();
      setIsPlaying(false);
    }
  }, []);

  const togglePlay = useCallback(() => {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }, [isPlaying, play, pause]);

  const seek = useCallback((time: number) => {
    if (videoRef.current && videoLoaded && time >= 0 && time <= duration) {
      videoRef.current.currentTime = time;
      setCurrentTime(time); // Optimistic update
    }
  }, [duration, videoLoaded]);

  const setVideoSource = useCallback((src: string | null) => {
    setCurrentVideoSrc(src);
    setIsPlaying(false);
    setCurrentTime(0);
    setDuration(0);
    setVideoLoaded(false);
  }, []);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const handleTimeUpdate = () => setCurrentTime(video.currentTime);
    const handleLoadedMetadata = () => {
      setDuration(video.duration);
      setVideoLoaded(true);
    };
    const handlePlay = () => setIsPlaying(true);
    const handlePause = () => setIsPlaying(false);
    const handleEnded = () => setIsPlaying(false);
    const handleError = (e: Event) => {
      console.error('Video error:', video.error);
      setVideoLoaded(false);
      setIsPlaying(false);
      setDuration(0);
      setCurrentTime(0);
      // alert(`Error loading video: ${video.error?.message || 'Unknown error'}`); // Optionally alert user
    };

    video.addEventListener('timeupdate', handleTimeUpdate);
    video.addEventListener('loadedmetadata', handleLoadedMetadata);
    video.addEventListener('play', handlePlay);
    video.addEventListener('pause', handlePause);
    video.addEventListener('ended', handleEnded);
    video.addEventListener('error', handleError);

    if (currentVideoSrc) {
      video.src = currentVideoSrc;
      video.load();
    } else {
      video.removeAttribute('src');
      video.load();
    }

    return () => {
      video.removeEventListener('timeupdate', handleTimeUpdate);
      video.removeEventListener('loadedmetadata', handleLoadedMetadata);
      video.removeEventListener('play', () => setIsPlaying(true));
      video.removeEventListener('pause', () => setIsPlaying(false));
      video.removeEventListener('ended', handleEnded);
      video.removeEventListener('error', handleError);
    };
  }, [currentVideoSrc]);

  return {
    videoRef,
    isPlaying,
    currentTime,
    duration,
    play,
    pause,
    togglePlay,
    seek,
    setVideoSource,
    videoLoaded,
    currentVideoSrc,
  };
};