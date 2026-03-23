'use client';

import { useState, useEffect } from 'react';
import styles from './Hero.module.css';

export default function Hero() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setMounted(true), 100);
    return () => clearTimeout(timer);
  }, []);

  return (
    <section id="home" className={styles.hero}>
      <div className={styles.grid} aria-hidden="true" />
      <div className={styles.content}>
        <div className={styles.eyebrow}>
          <span className={styles.tag}>MJC COMPUTER SECURITY CLUB</span>
        </div>
        <h1 className={styles.title}>
          <span
            className={`${styles.line} ${mounted ? styles.visible : ''}`}
            style={{ transitionDelay: '0.1s' }}
          >
            생각하고,
          </span>
          <span
            className={`${styles.line} ${mounted ? styles.visible : ''}`}
            style={{ transitionDelay: '0.25s' }}
          >
            만드는 사람들.
          </span>
        </h1>
        <p
          className={`${styles.sub} ${mounted ? styles.visible : ''}`}
          style={{ transitionDelay: '0.45s' }}
        >
          AI · 보안 · 개발에 관심 있는 대학생들이 모여<br />
          함께 배우고 성장하는 공간
        </p>
        <div
          className={`${styles.actions} ${mounted ? styles.visible : ''}`}
          style={{ transitionDelay: '0.6s' }}
        >
          <a href="#recruit" className={styles.btnPrimary}>
            모집 안내
          </a>
          <a href="#about" className={styles.btnSecondary}>
            동아리 소개
          </a>
        </div>
      </div>
    </section>
  );
}
