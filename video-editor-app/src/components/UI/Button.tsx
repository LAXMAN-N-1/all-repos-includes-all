// src/components/UI/Button.tsx
import React from 'react';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'ghost' | 'icon';
}

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  className = '',
  ...props
}) => {
  const baseClasses = 'inline-flex items-center justify-center font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-900 disabled:opacity-50 disabled:cursor-not-allowed';

  const variants = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 active:bg-blue-800 rounded-lg px-5 py-2 shadow-md focus:ring-blue-500',
    secondary: 'bg-gray-700 text-gray-200 hover:bg-gray-600 active:bg-gray-700 rounded-lg px-5 py-2 shadow-md focus:ring-gray-500',
    ghost: 'bg-transparent text-gray-300 hover:bg-gray-700 active:bg-gray-800 rounded-md px-3 py-1.5 focus:ring-gray-500',
    icon: 'bg-transparent text-gray-300 hover:bg-gray-700 active:bg-gray-800 rounded-full p-2 focus:ring-gray-500',
  };

  return (
    <button className={`${baseClasses} ${variants[variant]} ${className}`} {...props}>
      {children}
    </button>
  );
};