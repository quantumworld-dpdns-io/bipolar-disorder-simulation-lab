import { auth } from '@/auth.config';
import { NextResponse } from 'next/server';

export { auth as middleware };

export const config = {
  matcher: ['/api/:path*', '/dashboard/:path*', '/quantum/:path*'],
};