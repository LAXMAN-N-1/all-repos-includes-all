// src/data/mockData.ts

export const SAMPLE_VIDEO_URL = "https://www.w3schools.com/html/mov_bbb.mp4";

export interface KeyMoment {
  id: string; // Added ID for better React keying
  timestamp: number; // in seconds
  title: string;
}

export interface VideoSegment { // Renamed to avoid conflict if you had a different 'VideoSegment' in your app
  id: string; // Added ID for better React keying
  start: number; // in seconds
  end: number; // in seconds
  type: "silent" | "highlighted";
}

export const mockKeyMoments: KeyMoment[] = [
  { id: "km1", timestamp: 5, title: "Deer Arrival" },
  { id: "km2", timestamp: 15, title: "Squirrel's Plan" },
  { id: "km3", timestamp: 28, title: "Raccoon Interaction" },
  { id: "km4", timestamp: 40, title: "Bird's Song" },
  { id: "km5", timestamp: 55, title: "Sunset Scene" },
];

export const mockVideoSegments: VideoSegment[] = [
  { id: "vs1", start: 0, end: 4, type: "silent" },
  { id: "vs2", start: 10, end: 12, type: "highlighted" },
  { id: "vs3", start: 20, end: 23, type: "silent" },
  { id: "vs4", start: 35, end: 38, type: "highlighted" },
  { id: "vs5", start: 48, end: 52, type: "silent" },
];