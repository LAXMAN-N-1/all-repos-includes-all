'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { NavItem } from '@/types';
import * as Icons from 'lucide-react';
import { LucideIcon } from 'lucide-react';

interface Props {
  navItems: NavItem[];
}

export default function Sidebar({ navItems }: Props) {
  const pathname = usePathname();

  const getIcon = (iconName: string) => {
    const Icon = (Icons as any)[iconName] as LucideIcon;
    return Icon ? <Icon className="w-5 h-5" /> : <Icons.Circle className="w-5 h-5" />;
  };

  return (
    <aside className="w-64 bg-white border-r border-gray-200 h-screen sticky top-0">
      {/* Logo */}
      <div className="h-16 flex items-center px-6 border-b border-gray-200">
        <h1 className="text-xl font-bold text-blue-600">HRMS</h1>
      </div>

      {/* Navigation */}
      <nav className="p-4 space-y-1">
        {navItems.map((item) => {
          const isActive = pathname === item.path;
          
          return (
            <Link
              key={item.id}
              href={item.path}
              className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                isActive
                  ? 'bg-blue-50 text-blue-600 font-medium'
                  : 'text-gray-700 hover:bg-gray-50'
              }`}
            >
              {getIcon(item.icon)}
              <span>{item.label}</span>
              {item.badge && (
                <span className="ml-auto bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">
                  {item.badge}
                </span>
              )}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
