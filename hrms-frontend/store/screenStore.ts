import { create } from 'zustand';
import { Screen, NavItem } from '@/types';
import { screenAPI } from '@/lib/api';

interface ScreenState {
  screens: Screen[];
  navItems: NavItem[];
  loading: boolean;
  error: string | null;
  fetchUserScreens: (userId: string) => Promise<void>;
}

export const useScreenStore = create<ScreenState>((set) => ({
  screens: [],
  navItems: [],
  loading: false,
  error: null,

  fetchUserScreens: async (userId: string) => {
    set({ loading: true, error: null });
    try {
      const response = await screenAPI.getUserScreens(userId);
      const screens = response.data;
      
      // Convert screens to nav items
      const navItems: NavItem[] = screens.map((screen: Screen) => ({
        id: screen.id,
        label: screen.name,
        path: screen.path,
        icon: screen.icon,
      }));

      set({ screens, navItems, loading: false });
    } catch (error) {
      set({ 
        error: 'Failed to load screens', 
        loading: false 
      });
    }
  },
}));
