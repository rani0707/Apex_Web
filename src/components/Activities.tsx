'use client';

import { useScrollReveal } from '@/hooks/useScrollReveal';
import { Brain, Lock, Layers } from 'lucide-react';
import styles from './Activities.module.css';
import type { Activity } from '@/lib/fetchers';

interface Props {
  tracks: Activity[];
}

const iconMap: Record<string, React.ReactNode> = {
  '01': <Brain size={28} strokeWidth={1.5} />,
  '02': <Lock size={28} strokeWidth={1.5} />,
  '03': <Layers size={28} strokeWidth={1.5} />,
};

export default function Activities({ tracks }: Props) {
  const sectionRef = useScrollReveal<HTMLElement>();

  return (
    <section id="activities" className={styles.section} ref={sectionRef.ref}>
      <div className={styles.container}>
        <div className={styles.sectionHead}>
          <div className={styles.label}>02 / ACTIVITIES</div>
          <h2 className={`${styles.title} reveal`}>활동 트랙</h2>
          <p className={`${styles.subtitle} reveal reveal-delay-1`}>
            보안 입문자부터 취업 준비생까지,<br />
            누구나 자신의 수준에 맞춰 시작할 수 있습니다.
          </p>
        </div>
        <div className={styles.trackList}>
          {tracks.map((track, i) => (
            <div key={track.number} className={`${styles.trackCard} reveal reveal-delay-${i + 1}`}>
              <div className={styles.trackNum}>{track.number}</div>
              <div className={styles.trackIcon}>{iconMap[track.number] ?? null}</div>
              <div className={styles.trackInfo}>
                <h3 className={styles.trackTitle}>{track.title}</h3>
                <p className={styles.trackSubtitle}>{track.subtitle}</p>
              </div>
              <div className={styles.trackTags}>
                {track.tags.map((tag) => (
                  <span key={tag} className={styles.tag}>{tag}</span>
                ))}
              </div>
              <p className={styles.trackDesc}>{track.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
