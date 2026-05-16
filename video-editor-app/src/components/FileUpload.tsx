// src/components/FileUpload.tsx
import React, { useCallback, useRef } from 'react';
import { Button } from './UI/Button';
import { SAMPLE_VIDEO_URL } from '../data/mockData';

interface FileUploadProps {
  onFileSelect: (file: File) => void;
  onUseSample: (url: string) => void;
}

export const FileUpload: React.FC<FileUploadProps> = React.memo(({ onFileSelect, onUseSample }) => {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = useCallback((event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file && file.type.startsWith('video/')) {
      onFileSelect(file);
    } else if (file) {
      alert('Please select a valid video file (.mp4, .mov, etc.).');
      if (fileInputRef.current) {
        fileInputRef.current.value = ''; // Clear the input
      }
    }
  }, [onFileSelect]);

  const triggerFileInput = useCallback(() => {
    fileInputRef.current?.click();
  }, []);

  return (
    <div className="flex flex-col md:flex-row items-center gap-3">
      <Button onClick={triggerFileInput} variant="primary">
        Upload Video
        <input
          type="file"
          accept="video/*"
          onChange={handleFileChange}
          ref={fileInputRef}
          className="hidden"
        />
      </Button>
      <span className="text-gray-400 text-sm">or</span>
      <Button onClick={() => onUseSample(SAMPLE_VIDEO_URL)} variant="secondary">
        Use Sample Video
      </Button>
    </div>
  );
});