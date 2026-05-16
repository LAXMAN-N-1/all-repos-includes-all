// src/components/Timeline/TimelineUtils.ts

export const calculatePosition = (time: number, totalDuration: number, timelineWidthPx: number): number => {
    if (totalDuration === 0 || timelineWidthPx === 0) return 0;
    return (time / totalDuration) * timelineWidthPx;
};

export const calculateWidth = (durationSeconds: number, totalDuration: number, timelineWidthPx: number): number => {
    if (totalDuration === 0 || timelineWidthPx === 0) return 0;
    return (durationSeconds / totalDuration) * timelineWidthPx;
};