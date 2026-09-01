import styles from './Footer.module.css';
import { Mail } from 'lucide-react';
import { sanitizeMailto } from '@/lib/url';

interface Props {
  contactEmail: string;
}

export default function Footer({ contactEmail }: Props) {
  const safeMailto = sanitizeMailto(contactEmail);

  return (
    <footer className={styles.footer}>
      <div className={styles.container}>
        <div className={styles.top}>
          <div className={styles.brand}>
            <span className={styles.logo}>APEX</span>
            <p className={styles.brandDesc}>
              컴퓨터보안공학과 본과정 동아리<br />
              AI · 보안 · 개발, 함께 성장하는 공간
            </p>
          </div>
          <div className={styles.links}>
            <div className={styles.linkGroup}>
              <h4 className={styles.linkTitle}>탐색</h4>
              <ul className={styles.linkList}>
                <li><a href="#home" className={styles.link}>홈</a></li>
                <li><a href="#about" className={styles.link}>소개</a></li>
                <li><a href="#activities" className={styles.link}>활동</a></li>
                <li><a href="#projects" className={styles.link}>프로젝트</a></li>
                <li><a href="#awards" className={styles.link}>수상</a></li>
                <li><a href="#recruit" className={styles.link}>모집</a></li>
              </ul>
            </div>
            <div className={styles.linkGroup}>
              <h4 className={styles.linkTitle}>연락처</h4>
              <ul className={styles.linkList}>
                {safeMailto ? (
                  <li>
                    <a href={safeMailto} className={styles.link}>
                      {contactEmail}
                    </a>
                  </li>
                ) : (
                  <li>
                    <span className={styles.link}>연락처 정보가 설정되지 않았습니다.</span>
                  </li>
                )}
              </ul>
              <div className={styles.socials}>
                {safeMailto && (
                  <a href={safeMailto} className={styles.social} aria-label="이메일">
                    <Mail size={18} strokeWidth={1.5} />
                  </a>
                )}
              </div>
            </div>
          </div>
        </div>
        <div className={styles.bottom}>
          <span className={styles.copy}>© 2026 APEX. All rights reserved.</span>
          <span className={styles.copy}>MJC COMPUTER SECURITY CLUB</span>
        </div>
      </div>
    </footer>
  );
}
