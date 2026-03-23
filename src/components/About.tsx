'use client';

import { useScrollReveal } from '@/hooks/useScrollReveal';
import { Cpu, Shield, Code2 } from 'lucide-react';
import styles from './About.module.css';

interface ValueItem {
  title: string;
  desc: string;
}

interface Props {
  intro: string;
  values: ValueItem[];
}

const iconMap: Record<string, React.ReactNode> = {
  AI: <Cpu size={24} strokeWidth={1.5} />,
  보안: <Shield size={24} strokeWidth={1.5} />,
  개발: <Code2 size={24} strokeWidth={1.5} />,
};

export default function About({ intro, values }: Props) {
  const sectionRef = useScrollReveal<HTMLElement>();

  return (
    <section id="about" className={styles.section} ref={sectionRef.ref}>
      <div className={styles.container}>
        <div className={styles.header}>
          <div className={styles.label}>01 / ABOUT</div>
          <h2 className={`${styles.title} reveal`}>APEX란?</h2>
          <p className={`${styles.desc} reveal reveal-delay-1`}>
            {intro}
          </p>
        </div>
        <div className={styles.grid}>
          {values.map((v, i) => (
            <div key={v.title} className={`${styles.card} reveal reveal-delay-${i + 1}`}>
              <div className={styles.icon}>{iconMap[v.title] ?? null}</div>
              <h3 className={styles.cardTitle}>{v.title}</h3>
              <p className={styles.cardDesc}>{v.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
