import DynamicLayout from '@/components/layout/DynamicLayout';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <DynamicLayout>{children}</DynamicLayout>;
}
