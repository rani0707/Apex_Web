import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'MJC — APEX',
  description: 'AI, 보안, 개발에 관심 있는 대학생들이 모여 함께 배우고 성장하는 동아리',
  icons: {
    icon: '/favicon.svg',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}
