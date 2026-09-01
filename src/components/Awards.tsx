'use client';

import { Trophy, Medal, Star } from 'lucide-react';
import styles from './Awards.module.css';
import type { Award } from '@/lib/fetchers';

interface Props {
  awards: Award[];
}

const getIcon = (result: string) => {
  if (result.includes('최우수')) return <Trophy size={18} strokeWidth={1.5} />;
  if (result.includes('우수') || result.includes('동상') || result.includes('장려')) return <Medal size={18} strokeWidth={1.5} />;
  return <Star size={18} strokeWidth={1.5} />;
};

export default function Awards({ awards }: Props) {
  return (
    <section id="awards" className={styles.section}>
      <div className={styles.container}>
        <div className={styles.sectionHead}>
          <div className={styles.label}>04 / AWARDS</div>
          <h2 className={styles.title}>수상 이력</h2>
          <p className={styles.subtitle}>
            APEX 구성원이 달성한<br />
            다양한 수상 경력을 소개합니다.
          </p>
        </div>
        <div className={styles.awardsTable}>
          <div className={styles.tableHeader}>
            <span className={styles.headerYear}>연도</span>
            <span className={styles.headerTitle}>수상명</span>
            <span className={styles.headerOrg}>주최</span>
            <span className={styles.headerResult}>결과</span>
          </div>
          <div className={styles.tableBody}>
            {awards.map((award, i) => (
              <div key={i} className={styles.tableRow}>
                <span className={styles.year}>{award.year}</span>
                <span className={styles.awardTitle}>{award.title}</span>
                <span className={styles.org}>{award.organization}</span>
                <span className={styles.result}>
                  <span className={styles.resultBadge}>
                    {getIcon(award.result)}
                    {award.result}
                  </span>
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
