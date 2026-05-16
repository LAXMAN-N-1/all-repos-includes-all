'use client';

import { useState, useEffect } from 'react';
import { screenAPI } from '@/lib/api';
import { Screen } from '@/types';
import Card from '../common/Card';
import Button from '../common/Button';

interface Props {
  userId: string;
  userName: string;
  onClose?: () => void;
}

export default function ScreenAssignment({ userId, userName, onClose }: Props) {
  const [allScreens, setAllScreens] = useState<Screen[]>([]);
  const [selectedScreens, setSelectedScreens] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadScreens();
  }, []);

  const loadScreens = async () => {
    try {
      const response = await screenAPI.getAllScreens();
      setAllScreens(response.data);
    } catch (error) {
      console.error('Failed to load screens');
    }
  };

  const handleToggleScreen = (screenId: string) => {
    setSelectedScreens(prev =>
      prev.includes(screenId)
        ? prev.filter(id => id !== screenId)
        : [...prev, screenId]
    );
  };

  const handleSave = async () => {
    setLoading(true);
    try {
      await screenAPI.assignScreens(userId, selectedScreens);
      alert('Screens assigned successfully!');
      onClose?.();
    } catch (error) {
      alert('Failed to assign screens');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card title={`Assign Screens to ${userName}`}>
      <div className="space-y-3 mb-6 max-h-96 overflow-y-auto">
        {allScreens.map((screen) => (
          <label
            key={screen.id}
            className="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer"
          >
            <input
              type="checkbox"
              checked={selectedScreens.includes(screen.id)}
              onChange={() => handleToggleScreen(screen.id)}
              className="w-4 h-4 text-blue-600"
            />
            <div className="flex-1">
              <div className="font-medium text-gray-900">{screen.name}</div>
              <div className="text-sm text-gray-500">{screen.description}</div>
            </div>
          </label>
        ))}
      </div>

      <div className="flex gap-3">
        <Button onClick={handleSave} loading={loading} className="flex-1">
          Save Assignment
        </Button>
        {onClose && (
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
        )}
      </div>
    </Card>
  );
}
