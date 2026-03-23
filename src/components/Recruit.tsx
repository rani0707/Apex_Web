'use client';

import { useScrollReveal } from '@/hooks/useScrollReveal';
import { Calendar, MapPin, Users, Clock, Bell } from 'lucide-react';
import styles from './Recruit.module.css';
import type { TimelineItem, Perk } from '@/lib/fetchers';

interface Props {
  timeline: TimelineItem[];
  perks: Perk[];
  isOpen: boolean;
  closedMessage: string;
  recruitFormUrl: string;
}

const iconMap: Record<string, React.ReactNode> = {
  users: <Users size={20} strokeWidth={1.5} />,
  mapPin: <MapPin size={20} strokeWidth={1.5} />,
  calendar: <Calendar size={20} strokeWidth={1.5} />,
  clock: <Clock size={20} strokeWidth={1.5} />,
};

export default function Recruit({ timeline, perks, isOpen, closedMessage, recruitFormUrl }: Props) {
  const sectionRef = useScrollReveal<HTMLElement>();

  return (
    <section id="recruit" className={styles.section} ref={sectionRef.ref}>
      <div className={styles.container}>
        <div className={styles.sectionHead}>
          <div className={styles.label}>05 / RECRUIT</div>
          <h2 className={`${styles.title} reveal`}>모집 안내</h2>
          <p className={`${styles.subtitle} reveal reveal-delay-1`}>
            보안을 처음 접하는 입문자부터<br />
            취업 준비생까지, 누구나 자유롭게 참여할 수 있습니다.
          </p>
        </div>
        <div className={styles.content}>
          <div className={styles.timeline}>
            {timeline.map((item, i) => (
              <div key={i} className={`${styles.timelineItem} reveal reveal-delay-${i + 1}`}>
                <div className={styles.timelineLeft}>
                  <div className={styles.dot} />
                  {i < timeline.length - 1 && <div className={styles.line} />}
                </div>
                <div className={styles.timelineContent}>
                  <span className={styles.period}>{item.period}</span>
                  <h3 className={styles.timelineTitle}>{item.title}</h3>
                  <p className={styles.timelineDesc}>{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
          <div className={styles.rightPanel}>
            <div className={`${styles.perksCard} reveal`}>
              <h3 className={styles.perksTitle}>APEX에서 제공하는 것</h3>
              <ul className={styles.perksList}>
                {perks
                  .filter((p) => p.show)
                  .map((perk) => (
                    <li key={perk.label} className={styles.perk}>
                      {iconMap[perk.icon] ?? null}
                      <span>{perk.label}</span>
                    </li>
                  ))}
              </ul>
            </div>
            {isOpen ? (
              <div className={`${styles.ctaCard} reveal reveal-delay-2`}>
                <p className={styles.ctaText}>관심이 있으신가요?</p>
                <h3 className={styles.ctaTitle}>함께 시작해보세요.</h3>
                <a
                  href={recruitFormUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className={styles.ctaBtn}
                >
                  신청서 작성하러 가기
                </a>
              </div>
            ) : (
              <div className={`${styles.closedCard} reveal reveal-delay-2`}>
                <div className={styles.closedIcon}>
                  <Bell size={28} strokeWidth={1.5} />
                </div>
                <p className={styles.closedText}>{closedMessage}</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
